return {
	filetypes = { "python" },
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
				autoSearchPaths = true,
				autoImportCompletions = true,
				diagnosticSeverityOverrides = {
					reportUnusedImport = "none",
					reportUnusedVariable = "none",
				},
			},
		},
	},
}
