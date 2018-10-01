# Automate WP setup

This bash script automates the process of setting up new WP dev environments. Mainly testen on windows environments and is also compatible to run in WSL.

## What is does

The script does the following tasks when running:

- create a folder in the location set in the bash file in the following format: projectname.local
- clones [BedRock](https://github.com/roots/bedrock) in this folder
- removes .git folders from the bedrock clone
- clones [BasePlate](https://github.com/Levdbas/BasePlate) in the theme folders and moves all the files to the right folders, removes .git folder as well
- runs yarn for npm packages with fallback to npm install
- runs composer
- creates git repo in the project folder, adds _node_modules_ to the _.gitignore_
- set remote for git repo
- creates .env file and fills it with correct values (check if values are correct for you)
- generates and sets salts in .env file
- installs WordPress with wp-cli, sets permalink structure and active theme.
- updates example page to be the static front-page

## Prerequisites

The following is needed before you can run the script.

- duplicate example.variables.config to variables.config and fill in the details
- install LTS or latest version of node.js
- Install latest version of composer
- install latest version of yarn
- install GIT
- add mysql to path
  - MAC: _export PATH=${PATH}:/usr/local/mysql/bin/_
  - Windows: follow this [tutorial](https://www.qualitestgroup.com/resources/knowledge-center/how-to-guide/add-mysql-path-windows/)
  - Windows wsl _apt install mariadb-client-core-10.1 -y_
- install wp-cli with install wp-cli with: composer global require wp-cli/wp-cli
- instal dotenv with: wp package install aaemnnosttv/wp-cli-dotenv-command:^1.0

## Contributing

Please let me know if you have suggestions for enhancements for this project

### To do

- Test script on mac/linux

## Authors

- **Erik van der Bas** - _Initial work_ - [Levdbas](https://github.com/levdbas)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
