$psake.use_exit_on_error = $true

properties {
}

Task default -depends Build

Task Build {
}

Task Scrape -depends Build {
    }

Task Export {
    }

