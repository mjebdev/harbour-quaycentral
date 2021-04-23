# QuayCentral
A GUI app for the 1Password command-line tool on Sailfish OS.

QuayCentral is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.

Licensed under GNU GPLv3.

<h3>Requirements</h3>

- Installation of the 1Password command-line tool in /usr/local/bin or another directory in your $PATH. (The app has not been tested with the tool in a location other than /usr/local/bin). More info and download link:<br>
    https://support.1password.com/command-line-getting-started/<br>
    https://app-updates.agilebits.com/product_history/CLI
- Addition of the shorthand "quaycentsfos" to your device's CLI. The shorthand is device-specific. More info on adding the shorthand is available at:<br>
    https://support.1password.com/command-line-reference/#options-for-signin &<br>
    https://1password.community/discussion/comment/561753/#Comment_561753

<h3>Rationale</h3>

- Having a 1Password client that keeps Ambience on user's device, providing for a better and more consistent SFOS experience.
- Official 1Password app that supports 1Password.com accounts requires Android version 5 or greater and is therefore incompatible with Alien Dalvik on Xperia X.
- Overall plus to have more native SFOS apps and fewer dependencies on Android versions, experimenting with how different apps may utilize the interface that SFOS provides.

<h3>Limitations & Issues</h3>

- As of now, only shows items in the Login category and shows username, password, and one-time password (if applicable) for each item. Plan to add more categories and eventually all.
- Items are read-only, plan to add editing capability at some point in the future.
- Timeout only applies to the app's interaction with the CLI, i.e. swiping back a page, going to Settings, or scrolling down a list, etc. will not reset the lockout timer.
- Leaving the app open on an item details page that includes a TOTP (one-time password) will mean the lockout timer never times out, as it will keep resetting every 30 seconds a new code is generated.
- No support for multiple accounts or for groups. (No plans for this, app is designed for individual use.)
- Items are not listed alphabetically so search method is, for now, necessary as opposed to scrolling through a list.
- Option to select a default vault and possibly more vault management, similar to the official app, is on hold until I have a Sailfish Secrets implementation to provide the secure storage that may be required for data such as a default vault UUID.
- Clipboard icon on item details page may be somewhat misaligned if text size is enlarged on a device's Display Settings. Will edit code to work around this somehow, prefer the medium clipboard icon to the small one, there is no small-plus icon size for the clipboard icon as of now.
- Lock icon on cover may appear somewhat smaller than other standard cover icons. No lock icon available under the Cover category so went with the small icon for now.
- Icon could use improvement or replacement.

<h3>Privacy & Security</h3>

- User can lock the vault(s) by swiping back to Sign-in page, or choosing 'Lock' on the push-up menu on the Item Details page. Another option is to tap the padlock on the app Cover on the home screen.
- By assigning the shorthand 'quaycentsfos', app is able to avoid requiring any secrets to be stored. User also has control over what accounts the shorthand is or is not associated with, incase they'd like to use the CLI for separate accounts and not use a GUI for all, or to continue using the CLI after revoking QuayCentral signin access, etc. While the default domain value 'my' is now the only option available to new users (AFAIK), it was the case previously that personalized domains could be chosen, hence the classification of this data as secret.
- Master password entered by user is cleared immediately following its passing to the CLI and is never stored. Item usernames and passwords are only ever in RAM, are cleared when the vault is locked, and are only copied to the clipboard if user so chooses.
- May add timer so that user can designate a time after which clipboard is cleared following a password or username being copied. It will require a string variable in RAM to cross reference clipboard contents (and avoid deleting separate data that user may have put on clipboard in the meantime), after which both clipboard and string variable will be erased.
- When removing the login access for QuayCentral, user will need to get back into Terminal but may also need to remove the CLI from authorized devices on their 1Password profile page. Info on how to sign out directly in Terminal, as well as using the 'forget' flag and command, are here:<br>
    https://support.1password.com/command-line-reference/#signout<br>
    https://support.1password.com/command-line-reference/#forget
- Overall the app is able to avoid privacy or security issues due to the CLI naturally handling all of that processing and encryption.

<h3>Contact</h3>

If you would like to send feedback regarding the app, please email: mjbarrett@eml.cc

If you'd like to support my work in developing native Sailfish OS apps 👍 <a href="https://buymeacoffee.com/michaeljb">buy me a coffee</a>!<br>
<br>
Thanks,<br>
Michael B.
