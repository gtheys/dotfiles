import type { Plugin } from "@opencode-ai/plugin"

export const Notify: Plugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await Promise.all([
          $`pw-play /usr/share/sounds/freedesktop/stereo/complete.oga`,
          $`notify-send -a opencode -i ~/.local/share/icons/opencode.svg "Session completed!"`
        ])
      }
      if (event.type === "permission.updated") {
        await Promise.all([
          $`pw-play /usr/share/sounds/freedesktop/stereo/message-new-instant.oga`,
          $`notify-send -a opencode -i ~/.local/share/icons/opencode.svg "Permission Requested:" "${event.properties.type === 'bash' ? '$' : ''} ${event.properties.title}"`
        ])
      }
    },
  }
}
