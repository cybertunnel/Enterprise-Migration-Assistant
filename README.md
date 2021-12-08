# Enterprise Migration Assistant

Based off of [alectrona/migrator](https://github.com/alectrona/migrator)

This application provides a nice interface to handle branding, prompting, and other user interactions while performing the same level of tasks that the above reference does.

Functionality:
- Accepts custom branding
- Has `rsync` version `3.1.3` included
- Potentially uses `docklib` to handle dock manipulation
- Provides insight on how to handle Apple Silicon and Intel target disk modes
- Verify user's local password
- Verify user's remote password
- Checks for disk space on local disk
- Prompts if old or local password is to be used
- Has debug option that does not actually move stuff
- Creates local LaunchDaemon that goes over LoginWindow to prevent user from logging in


Process:
- Welcome screen
- Disk detection/selection
- User folder detection/selection
- Password prompt
- Transfer files to local drive
- Attempt prompt for privledged helper
- Install LaunchDaemon that kicks off the rsync
- Migration user is created with a Secure Token
- Copy data to current disk's /Users/ folder
- Remove existing user if it already matches
- user migrated created by the migrator user w/ Secure Token
- migrator user and supporting files are removed from the computer


Engine:
- Check Secure Token Status (throws error)
- Calculate space requirement
- perform rsync
- manually find old user
- auto find old user
- choose tbolt volume
- detect new tbolt volumes
- get user password
- get old user password
- check user password against old keychain
- confirm conflicting user deletion
- isUserReadyForThis
- make migrator user
- writeMigrationSettings
- writeLaunchDaemon
- start LaunchDaemon
- 
