# Automate WP setup

This bash script automates the process of setting up new WP dev environments.

## What is does

The script does the following tasks when running:

* create a folder in the location set in the bash file in the following format: projectname.local
* clones [BedRock](https://github.com/roots/bedrock) in this folder
* removes .git folders from the bedrock clone
* clones [BasePlate](https://github.com/Levdbas/BasePlate) in rhe theme folders and moves all the files to the right folders, removes .git folder as well
* runs yarn for npm packages with fallback to npm install
* runs composer
* creates git repo in the project folder, adds *node_modules* to the *.gitignore*
* creates .env file and fills it with correct values (check if values are correct for you)
* generates and sets salts in .env file
* installs WordPress with wp-cli & blocks search engines in the WP settings

## Prerequisites

The following is needed before you can run the script.

* install LTS or latest version of node.js
* Install latest version of composer
* install latest version of yarn
* install GIT
* add mysql to path
  * MAC: *export PATH=${PATH}:/usr/local/mysql/bin/*
  * Windows: follow this [tutorial](https://www.qualitestgroup.com/resources/knowledge-center/how-to-guide/add-mysql-path-windows/)
* install wp-cli with install wp-cli with: composer global require wp-cli/wp-cli
* instal dotenv with: wp package install aaemnnosttv/wp-cli-dotenv-command:^1.0

## Contributing

Please let me know if you have suggestions for enhancements for this project. I would like to make it more modular variable.
So you can choose your own theme etc of your choice.

### To do

* Test script on mac/linux
* Make the script more modular, so the script can be easier finetuned for your liking
* Make an addition to clone an existing project to setup locally and check in a smart way which tasks to run.

## Authors

* **Erik van der Bas** - *Initial work* - [Levdbas](https://github.com/levdbas)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
