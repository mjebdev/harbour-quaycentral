# QuayCentral
A read-only GUI for the 1Password command-line tool on Sailfish OS.

Version 0.9.2

QuayCentral is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.

App icon by <a href="https://github.com/JSEHV">JSEHV</a>. Thanks for the contribution!

Please note: The email address in the About section of versions 0.5 and 0.5.1 (qc at mjbdev.net) is no longer active and that domain is no longer owned by myself. Please send any feedback to: feedback@mjeb.dev

<h3>Requirements</h3>

- A 1Password.com account.
- An active network connection.
- Installation of version 2.20.0 or later of the 1Password command-line tool in /usr/bin, /usr/local/bin, or another directory in your $PATH. More info:<br>
    https://developer.1password.com/docs/cli/get-started/
- Addition of the shorthand "quaycentsfos" to your device's CLI. This avoids the need for QC to store your address for signing in (in most cases 'my' but not always). It can be done from the app or independtly using Terminal. More info on adding the shorthand:<br>
    https://developer.1password.com/docs/cli/sign-in-manually/#set-a-custom-account-shorthand
- Tested on SFOS 4.5 & 4.6.

<h3>Limitations & Issues</h3>

- Lockout timer may not function if device is put to sleep etc. and so is not meant as a reliable replacement for manually locking vault(s) using one of the available methods.
- Lockout timer only goes by the app's interaction with the CLI and isn't reset by any user interaction that doesn't access data, such as swiping back, going to Settings, etc. If part of an item, the one-time password is obtained every 30 seconds using the CLI but can be stopped from continuing by using the Close button on the app cover or just swiping back from the item details if inside the app.
- One-time password will sometimes disappear from Cover and the Item page in the app after loading, reason as yet unknown. Will fix as soon as cause is identified.
- No support for multiple accounts or for groups.
- No support for creating new items or editing items as of now. Uploading and downloading of documents is supported but otherwise app is read-only. Hope to add option to create an item in the future but technical issues (likely to do with permissions involving CLI) preventing this so far.

<h3>Minor Limitations</h3>

- Documents won't show up in list of items when all categories are loaded, to get to them user must go to the Documents section from the Vault(s) page.
- Item details page should list all data entries, however will not display section headers (besides Notes) and may still have some formatting issues in some cases.
- Items are not listed alphabetically so search method is necessary as opposed to scrolling through a list.
- Clipboard and zoom icons on item details page may be somewhat misaligned if text size is enlarged on a device's display settings.

<h3>Rationale</h3>

- Official 1Password app that supports 1Password.com accounts requires Android version 5 or greater and is incompatible with Android app support on Xperia X, and of course devices without any Android app support as well.
- A positive to have more native SFOS apps and fewer dependencies on Android versions.

<h3>Privacy & Security</h3>

- Users can lock the vault(s) by tapping the padlock button on the app's cover icon, swiping back in the app to the Sign-in page, or choosing 'Lock' on the pull-down menu on any other page, if this option is enabled (on by default).
- Master password entered by user is cleared immediately following its passing to the CLI and is never stored. Same goes for all fields when entering in login info to add shorthand from the app. Item usernames and passwords are only ever in RAM, are cleared when the vault is locked, and are only copied to the clipboard if user so chooses.
- Default vault UUID, if one is chosen, is stored as a setting (this string does not contain any data regarding the contents nor the name of the vault).
- When removing the shorthand access for QuayCentral, user will need to get back into Terminal but may also remove the CLI from authorized devices on their 1Password profile page. More info on revoking access:<br>
    https://developer.1password.com/docs/cli/reference/commands/signout<br>
    https://developer.1password.com/docs/cli/reference/management-commands/account/#account-forget

<h3>Tips</h3>

- <a href="https://ko-fi.com/michaeljb">Support me on Ko-fi</a>
- <a href="https://paypal.me/michaeljohnbarrett">PayPal</a>
