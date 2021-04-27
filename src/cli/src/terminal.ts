export const reset = '\x1b[0m'
export const bold = '\x1b[1m'
export const dim = '\x1b[2m'
export const underline = '\x1b[4m'
export const colors = {
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
  RED: '\x1b[31m'
}
export const error = colors.RED + '⨉' + reset
export const dot = colors.cyan + '•' + reset
export const check = colors.green + '✓' + reset
export const warn = colors.yellow + '!' + reset