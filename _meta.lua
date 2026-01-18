local _ = require("gettext")
return {
    name = "autoturn_compute",
    fullname = _("Autoturn Compute"),
    description = _("Measures reading speed (in seconds per page read) using an average of the last 10 pages to be used in autoturn plugin."),
}