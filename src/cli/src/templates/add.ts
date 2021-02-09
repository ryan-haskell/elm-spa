export default (page : string[]) : string => `
module Pages.${page.join('.')} exposing (page)

import View exposing (View)


page : View Never
page =
    View.placeholder "${page.join('.')}"

`.trimLeft()