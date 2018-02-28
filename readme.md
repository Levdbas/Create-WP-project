# Automate WP setup

This bash script automates the process of setting up new WP dev environments.

## What is does

* create a folder in the location set in the bash file in the following format: projectname.local
* clones [BedRock](http://www.dropwizard.io/1.0.2/docs/) in this folder
* removes .git folders from the bedrock clone
* clones [BasePlate](http://www.dropwizard.io/1.0.2/docs/) in rhe theme folders and moves all the files to the right folders, removes .git folder as well
* runs yarn for npm packages
* runs composer
* creates git repo in the project folder, adds *node_modules* to the *.gitignore*
* creates .env file and fills it with correct values (check if values are correct for you)
* generates and sets salts in .env file
* installs WordPress with wp-cli & blocks search engines in the WP settings

## Prerequisites

What things you need to install the software and how to install them

* node.js
* yarn
* composer
* add mysql to path
* install wp-cli with install wp-cli with: composer global require wp-cli/wp-cli
* instal dotenv with: wp package install aaemnnosttv/wp-cli-dotenv-command:^1.0

## Contributing

Please let me know if you have suggestions for enhancements for this project. I would like to make it more modular variable.
So you can choose your own theme etc of your choice.


## Authors

* **Erik van der Bas** - *Initial work* - [Levdbas](https://github.com/levdbas)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
