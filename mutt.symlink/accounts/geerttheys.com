# Account Settings -----------------------------------
set spoolfile = "+geerttheys.com/INBOX"

# Alternate email addresses.
#alternates 


# Other special folders.
set mbox      = "+geerttheys.com/archive"
set postponed = "+geerttheys.com/drafts"

color status green default

macro index D \
    "<save-message>+geerttheys.com/Trash<enter>" \
    "move message to the trash"

macro index S \
    "<save-message>+geerttheys.com/Spam<enter>"  \
        "mark message as spam"
