const vscode = require('vscode');
const path = require('path');
const fs = require('fs');

function activate(context) {
    const showManual = async () => {
        try {
            // Don't show if a project folder is already open.
            if (vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders.length > 0) {
                return;
            }

            // process.execPath points to the VSCodium executable at the bundle root.
            const bundleRoot = path.dirname(process.execPath);
            const manualPath = path.join(bundleRoot, 'manual', 'getting-started.md');

            if (!fs.existsSync(manualPath)) {
                return;
            }

            const uri = vscode.Uri.file(manualPath);
            await vscode.commands.executeCommand('markdown.showPreview', uri);
        } catch (err) {
            console.error('[vscodium-ops-toolkit-welcome]', err);
        }
    };

    // Delay slightly so the workbench is fully ready.
    setTimeout(showManual, 500);
}

function deactivate() {}

module.exports = { activate, deactivate };
