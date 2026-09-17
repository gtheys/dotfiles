#!/usr/bin/env python3
"""Pull Jira epic cycle times (IN project) and publish KPIs to a Confluence page.

Upserts page "Epic Cycle Time KPIs" in space SH: quarterly averages on top,
full per-epic table below. Regenerated from Jira every run, so rerunning adds
any new epics automatically. Uses Confluence v2 API + ADF (acli can't create pages).

Env: JIRA_API_TOKEN (Atlassian API token). Auth user hardcoded below.

Usage: ./jira_epic_kpis_confluence.py
"""
import base64
import datetime as dt
import json
import os
import statistics
import urllib.parse
import urllib.request

SITE = "https://salaryhero.atlassian.net"
EMAIL = "geert@salary-hero.com"
TOKEN = os.environ["JIRA_API_TOKEN"]
SPACE_ID = "262149"  # SH
PAGE_TITLE = "Epic Cycle Time KPIs (IN project)"

JQL = ('project="IN" AND issuetype=Epic '
       "AND customfield_10935 is not EMPTY AND customfield_10936 is not EMPTY")
FIELDS = "summary,customfield_10935,customfield_10936"

# AIDEV-NOTE: PI board = manual actions; counted by created month
PI_JQL = 'project="PI"'

AUTH = base64.b64encode(f"{EMAIL}:{TOKEN}".encode()).decode()


def api(path, method="GET", payload=None, base=SITE):
    url = base + path
    body = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Authorization", f"Basic {AUTH}")
    req.add_header("Accept", "application/json")
    if body:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as r:
        return json.load(r)


def parse_dt(v):
    if "T" in v:
        return dt.datetime.strptime(v[:19], "%Y-%m-%dT%H:%M:%S")
    return dt.datetime.fromisoformat(v)


def fetch_epics():
    epics = []
    token = None
    while True:
        q = ("?jql=" + urllib.parse.quote(JQL) +
             f"&maxResults=100&fields={FIELDS}")
        if token:
            q += f"&nextPageToken={token}"
        data = api("/rest/api/3/search/jql" + q)
        for i in data.get("issues", []):
            f = i["fields"]
            start, end = parse_dt(f["customfield_10935"]), parse_dt(f["customfield_10936"])
            days = (end - start).days
            if days <= 0:  # skip bad rows (negative/end-before-start) and 0-day test epics
                continue
            epics.append({
                "key": i["key"], "summary": f["summary"],
                "start": start.date().isoformat(), "end": end.date().isoformat(),
                "days": days, "quarter": f"{end.year}-Q{(end.month - 1) // 3 + 1}",
            })
        token = data.get("nextPageToken")
        if not token:
            return epics


def fetch_pi_created_months():
    months = {}
    token = None
    while True:
        q = ("?jql=" + urllib.parse.quote(PI_JQL) +
             "&maxResults=100&fields=created")
        if token:
            q += f"&nextPageToken={token}"
        data = api("/rest/api/3/search/jql" + q)
        for i in data.get("issues", []):
            m = i["fields"]["created"][:7]  # YYYY-MM
            months[m] = months.get(m, 0) + 1
        token = data.get("nextPageToken")
        if not token:
            return months


def cell(content, header=False):
    return {"type": "tableHeader" if header else "tableCell",
            "content": [{"type": "paragraph", "content": [content]}]}


def txt(s):
    return {"type": "text", "text": str(s)}


def link(text, href):
    return {"type": "text", "text": text, "marks": [{"type": "link", "attrs": {"href": href}}]}


def row(cells, header=False):
    return {"type": "tableRow", "content": [cell(c, header) for c in cells]}


def build_adf(epics, pi_months):
    # quarterly averages (by Done date)
    quarters = {}
    for e in epics:
        quarters.setdefault(e["quarter"], []).append(e["days"])
    q_rows = [row([txt("Quarter"), txt("Epics done"), txt("Avg days"),
                   txt("Median days")], header=True)]
    for q in sorted(quarters):
        d = quarters[q]
        q_rows.append(row([txt(q), txt(len(d)), txt(f"{statistics.mean(d):.1f}"),
                           txt(f"{statistics.median(d):.0f}")]))

    e_rows = [row([txt("Epic"), txt("Summary"), txt("Start (In Progress)"),
                   txt("End (Done)"), txt("Days")], header=True)]
    for e in sorted(epics, key=lambda x: -x["days"]):
        e_rows.append(row([
            link(e["key"], f"{SITE}/browse/{e['key']}"), txt(e["summary"][:80]),
            txt(e["start"]), txt(e["end"]), txt(e["days"])]))

    m_rows = [row([txt("Month"), txt("Tickets created")], header=True)]
    for m in sorted(pi_months):
        m_rows.append(row([txt(m), txt(pi_months[m])]))

    days = [e["days"] for e in epics]
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    return {
        "version": 1,
        "type": "doc",
        "content": [
            {"type": "paragraph", "content": [
                txt(f"Auto-generated {now} from Jira JQL: {JQL}. "
                    "Rerun script to refresh; new epics appear automatically. "
                    "Rows with duration <= 0 (bad/test data) excluded.")]},
            {"type": "heading", "attrs": {"level": 2},
             "content": [txt("Quarterly average cycle time (In Progress -> Done)")]},
            {"type": "table", "attrs": {"isNumberColumnEnabled": False,
                                        "layout": "default"},
             "content": q_rows},
            {"type": "heading", "attrs": {"level": 2},
             "content": [txt(f"Manual actions (PI board, {sum(pi_months.values())} tickets)")]},
            {"type": "table", "attrs": {"isNumberColumnEnabled": False,
                                        "layout": "default"},
             "content": m_rows},
            {"type": "heading", "attrs": {"level": 2},
             "content": [txt(f"All epics ({len(epics)})")]},
            {"type": "paragraph", "content": [
                txt(f"Overall: mean {statistics.mean(days):.1f} d, "
                    f"median {statistics.median(days):.0f} d, "
                    f"min {min(days)} d, max {max(days)} d")]},
            {"type": "table", "attrs": {"isNumberColumnEnabled": False,
                                        "layout": "wide"},
             "content": e_rows},
        ],
    }


def find_page():
    data = api(f"/wiki/api/v2/pages?spaceId={SPACE_ID}&title=" +
               urllib.parse.quote(PAGE_TITLE))
    pages = data.get("results", [])
    return pages[0]["id"] if pages else None


def main():
    epics = fetch_epics()
    pi_months = fetch_pi_created_months()
    print(f"fetched {len(epics)} valid epics, {sum(pi_months.values())} PI tickets")
    adf = json.dumps(build_adf(epics, pi_months))
    page_id = find_page()
    if page_id:
        cur = api(f"/wiki/api/v2/pages/{page_id}")
        payload = {"id": page_id, "status": "current", "title": PAGE_TITLE,
                   "body": {"representation": "atlas_doc_format", "value": adf},
                   "version": {"number": cur["version"]["number"] + 1}}
        api(f"/wiki/api/v2/pages/{page_id}", method="PUT", payload=payload)
        print(f"updated page {page_id}")
    else:
        payload = {"spaceId": SPACE_ID, "status": "current", "title": PAGE_TITLE,
                   "body": {"representation": "atlas_doc_format", "value": adf}}
        page = api("/wiki/api/v2/pages", method="POST", payload=payload)
        page_id = page["id"]
        print(f"created page {page_id}")
    print(f"{SITE}/wiki/spaces/SH/pages/{page_id}")


if __name__ == "__main__":
    main()
