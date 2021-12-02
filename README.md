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
