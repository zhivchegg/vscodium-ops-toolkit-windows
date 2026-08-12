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

            // The extension lives at VSCodium-portable/data/extensions/<name>.
            // Two levels up is the bundle root.
            const bundleRoot = path.dirname(path.dirname(context.extensionPath));
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
