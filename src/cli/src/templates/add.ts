export default (page: string[]): string => `
module Pages.${page.join('.')} exposing (view)

import View exposing (View)


view : View msg
view =
    View.placeholder "${page.join('.')}"

`.trimLeft()