# QuayCentral
QuayCentral (sounds like 'key') is a read-only and online-only GUI app for Sailfish OS that utilizes the 1Password Command-line Tool.  

Version 0.11  
Licensed under GNU GPLv3  
Built for SFOS v4.6+  

This is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.  

Thanks to [JSEHV](https://github.com/JSEHV) for the app icon.  

While the app is read-only (no creating, editing or deleting of items), a user can upload documents to their vault in the Documents section.  

With these limitations, this app is more of a supplement to the official Android app rather than an attempt at a full replacement.  

A reasonable approach might be to setup the Android app so that it is ready if needed, e.g. when offline or setting up 1Password on another device, and to have this native app, if so desired, for simpler actions such as password retrieval.  

What's new in version 0.11:
- Removed option to create new login items. This had only been functional if the app was launched via terminal, thus somewhat defeating the purpose of a GUI.
- Minor fixes and adjustments.

Release notes for previous versions are at [OpenRepos](https://openrepos.net/content/mjebdev/quaycentral).  

### Requirements

- A 1Password.com account.
- An active network connection.
- Installation of version 2.20.0 or later of the 1Password command-line tool in /usr/bin, /usr/local/bin, or another directory in your $PATH. More info:  
    https://developer.1password.com/docs/cli/get-started/
- Addition of the shorthand "quaycentsfos" to your device's CLI. This avoids the need for QC to store your address for signing in (in most cases 'my' but not always). It can be done from the app or independtly using Terminal. More info on adding the shorthand:  
    https://developer.1password.com/docs/cli/sign-in-manually/#set-a-custom-account-shorthand

### Limitations & Issues

- Lockout timer may not function if device is put to sleep etc. and so is not meant as a reliable replacement for manually locking vault(s) using one of the available methods.
- Lockout timer only goes by the app's interaction with the CLI and isn't reset by any user interaction that doesn't access data, such as swiping back, going to Settings, etc. If part of an item, the one-time password is obtained every 30 seconds using the CLI but can be stopped by using the Close button on the app cover, or by swiping back from the item details page in the app.
- One-time password will sometimes disappear from Cover and the Item page in the app after loading, reason as yet unknown. Will fix as soon as cause is identified. Only known workaround is to wait for another OTP with the app open.
- No support for multiple accounts or for groups.
- Documents won't show up in list of items when all categories are loaded, to get to them user must go to the Documents section from the Vault(s) page.
- Item details page should list all data entries, however will not display section headers (besides Notes) and may still have some formatting issues in some cases.
- Items are not listed alphabetically so search method is necessary as opposed to scrolling through a list.

### Rationale

- Good to have a native app with an interface consistent with Ambience.
- Less dependence on Android App Support.

### App Security

- Users can lock the vault(s) by tapping the padlock button on the app's cover icon, swiping back in the app to the Sign-in page, or choosing 'Lock' on the pull-down menu on any other page, if this option is enabled (on by default).
- Master password entered by user is cleared immediately following its passing to the CLI and is never stored. Same goes for all fields when entering in login info to add shorthand from the app. Existing item usernames and passwords are only ever in RAM, are cleared when the vault is locked, and are only copied to the clipboard if user so chooses.
- Default vault UUID, if one is chosen, is stored as a setting (this string does not contain any data regarding the contents or the name of the vault). Disabling the option in Settings will clear the stored string.
- If removing the shorthand access for QuayCentral, user will need to get back into Terminal but may also remove the CLI from authorized devices on their 1Password profile page. More info on revoking access:  
    https://developer.1password.com/docs/cli/reference/commands/signout  
    https://developer.1password.com/docs/cli/reference/management-commands/account/#account-forget
- A note on links in previous versions: GitHub and donation links were updated for version 0.9.3 and are broken on earlier versions. Please find updated donation links below. Also, the email address in the About section of versions 0.5 and 0.5.1 (qc at mjbdev.net) is now inactive. Please send any feedback to: [feedback@mjeb.dev](mailto:feedback@mjeb.dev)

### Tips

- [Buy Me a Coffee](https://buymeacoffee.com/mjebdev)
- [Ko-fi](https://ko-fi.com/mjebdev)
