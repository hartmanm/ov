# ov frontend and API, a centralized configuration and management system

## Overview

- ov scripts on user nodes control interaction with the ov API, using a single configuration file to access the user's account.

## Features
- **Centralized Management**: Change configurations for any number of nodes/machines from any internet-connected device.
- **User-Friendly Setup**: No need for user modification of the OS configuration file, simply download the configuration file from your account for each node/machine and put it on the configuration partition once.

## Technical Overview

### Architecture Components

1. **NoSQL Database**:     choose your xyz
2. **Back-end**:           Python
3. **Front-end**:          JavaScript
4. **Operating System**:   run scripts on your linux distro to turn it into a node

### Back-end

- Run the ov api with github pages or locally on linux distro
- The stateless back-end stores all data in the NoSQL database to ensure efficient scaling.
- A RESTful API is utilized to create, return, and modify database instances.

### Front-end

- JavaScript issues API calls to the back-end and dynamically generates DOM elements with user data based on the responses.
- User interactions trigger API calls that modify the database.
- Configuration files for rigs can be downloaded with a single button click.

### Operating System (ov)

- ov scripts modify your linux distro to turn it into a node.
- A Bash script controls interaction with the ov API, using configuration file data to access the user's account.
