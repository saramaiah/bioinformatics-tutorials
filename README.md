# Bioinformatics tutorials
## With everything you'll need and more

The purpose of this repository is to provide students with some background in biology an introduction to bioinformatics and a playground environment for hands-on learning. I've compiled tutorials in R (a basic intro as well as a guided tutorial in scRNA-seq data) and Python (NumPy, Pandas, and scikit-bio), as well as all of the packages needed to complete them as a first version release.

## Why Docker?

In my experience, using standard package management tools (think Python's `pip` or R's `install.packages()`) are easy, but cause a lot of problems as time goes on. Many of these packages are poorly maintained, so they aren't upgraded with their dependencies or the language itself. Eventually, two packages you're trying to use need conflicting versions of something, and everything breaks. Many tools exist to try to solve this, but they have problems too. Conda and its derivatives, for example, have a lot of flaws in their implementation that causes projects to break easily and unexpectedly. Most importantly, they're not reliably reproducible across systems, a necessity in science. The problem becomes a question of how we make our software replicable across any system?

Docker is a tool that packages software as *containers*. Containers are effectively the minimum set of information and instructions needed to tell a computer how to run a given program. The container simulates a base operating system, then installs packages and builds your software in that isolated environment. There are three key components to Docker:
- **Dockerfile**: A dockerfile is analagous to DNA. It is the source code that contains all of the instructions necessary for the Docker engine to build an image.
- **Image**: An image is a snapshot of software, files, and dependencies (including the base operating system). The image itself doesn't run any programs; it is an immutable "start point" from which you spin up containers.
  + In this analogy, building the image is the transcription, translation, and modification steps, producing a functional enzyme. Spinning up a container is then analagous to the enzyme performing its function. ~~(Except that Docker images are immutable and you can start multiple simultaneous containers from the same image, so the analogy kind of breaks down here)~~
- **Container**: A container is an instance of an image. This means that the programs you specified in the dockerfile and built in the image are actually run in the container. A container is an isolated environment that can run your software on any computer. The parameters you supply to the `docker run` command dictate some features of the container, like what ports or directories the programs can access (which you'll see in this tutorial). 

## Where do I start?

I've geared this tutorial to use a Docker image that contains all of the necessary packages. It is not strictly necessary that you follow this section, but it is recommended. Otherwise, look at the packages listed within the Dockerfile and install them with your package manager of choice.

### Installing Docker

For Windows and MacOS, you will need to install [Docker Desktop](https://docs.docker.com/get-started/get-docker/).
- Windows: If you are unsure what to do, download the latest version for x86_64 architecture (accessible at the top of the page or via the release notes page), and choose WSL 2 on the configuration page. I would also recommend installing interactively.
- MacOS: Your download depends on your CPU architecture. If unsure, go to 'About This Mac' via the Apple Menu, and look for a line that says chip/processor.
  + Apple silicon (M1/2/3/etc.): Installing Rosetta 2 is recommended. Open the Terminal and make sure you are in your home directory. Then, run `softwareupdate --install-rosetta`. Once that completes, continue to the interactive installation instructions.
  + Intel chip: Follow interactive installation instructions, no additional setup needed.
- Linux: If desired, install Docker Desktop for your Linux distribution. It is recommended to instead follow your distribution's instructions for Docker Engine installation, then use Docker from the terminal.

### Set up project folder

If downloaded as a zip archive, extract it in its own folder. You'll see this README (hi there!), a folder called `notebooks`, a file named `Dockerfile`, and a file named `docker-compose.yaml`. The other files in this folder were used in the tutorial's development, but you won't need to do anything with them. The `notebooks` folder contains both the Jupyter notebooks and associated datasets.

If you'd like to use this environment to make new projects, you can add notebooks, scripts, datasets, text files, new folders, etc. into this file structure. Keep in mind that in order to be accessible, they *must* be within the `notebooks` folder.

## Using Docker
### Create the Docker image

Open up Docker Desktop, then navigate to the console. Change your directory to be the project folder that you just extracted (e.g. `cd ~/Documents/bioinformatics-tutorials/`). Now, you have a few options:
  1. **Build the image locally**: Run `docker build -t <TAG> .` to build your image from the `Dockerfile` in the folder. 
    - The `-t <TAG>` flag is optional, but it lets you name the image something memorable. By default, its name will be a long alphanumeric string (result of sha256 hash). 
    - If you would like to modify the image and eventually publish it online, you should use the official syntax. The basic form is `<docker_username>/<image_name>:<version>`. For example, this image is published online as `saramaiah/bioinformatics-tutorials-jupyter-nb:latest`. See official documentation [here](https://docs.docker.com/reference/cli/docker/image/tag/).   
  2. **Pull the image from Docker Hub**: Run `docker image pull saramaiah/bioinformatics-tutorials-jupyter-nb:latest` to get the most recent version of the docker image from my Docker Hub account. The version originally published with this tutorial will be tagged as `saramaiah/bioinformatics-tutorials-jupyter-nb:1.0`, so you can pull that version and get the same software any time. 
    - Note that the same image can be given another tag (e.g. running `docker tag saramaiah/bioinformatics-tutorials-jupyter-nb:latest bioinfo`). Then, you won't have to type the long image name every time.

### Running the Docker container
Now it's time to actually get things running. After building or pulling the image, run `docker image ls` to see the images available to you. Either `<REPOSITORY>:<TAG>` or `<IMAGE ID>` is sufficient to specify the image. Now, make sure you are in the root of the project folder and run the following:

```
docker run -v ./notebooks:/home/jovyan/notebooks -p 8888:8888 saramaiah/bioinformatics-tutorials-jupyter-nb:latest
```

Alternatively, replace `saramaiah/bioinformatics-tutorials-jupyter-nb:latest` with your custom image tag, e.g.

```
docker run -v ./notebooks:/home/jovyan/notebooks -p 8888:8888 bioinfo:latest
```
or your image's ID (this is mine, yours may be different):
```
docker run -v ./notebooks:/home/jovyan/notebooks -p 8888:8888 03c4bead037c
```

#### Docker Compose (optional)

For users who prefer docker compose to the `docker run` command, I have included the file `docker-compose.yaml`. In order to use docker compose, you must first ensure that it is installed on your system by running `docker compose version`. If it isn't installed, see system-specific installation instructions in [official documentation](https://docs.docker.com/compose/). To use, simply run `docker compose up` in the root of the project directory. All of the parameters from the `docker run ...` command are specified in the file `docker-compose.yaml`, and they can be changed to suit user needs. For this application, it is completely equivalent to using `docker run`, but it is particularly useful for more advanced applications in which you need to define/run multiple containers.

### Using the Docker container

After running `docker run`, the terminal should output a lot of stuff, among which will be a link of the form `http://127.0.0.1:8888/lab?token=<STRING>` (the `localhost` one is equivalent). Click that link, and a browser tab will open to a Jupyter server page, from which you should see the `notebooks` folder. You will be able to run the code in all of the provided notebooks, as well as any new work you add. (*Limitation: if you choose to install new packages (e.g. R's `install.packages()` or Python's `pip install`), I cannot guarantee that they will work as expected.*) Any files added within the `notebooks` folder can be saved to disk, and when you exit the Docker container, they will still be accessible.

### Closing the Docker container

You can stop the container from running by pressing `CTRL+C` in the Docker Desktop terminal window. This will shut down the Jupyter server, but it will not delete any **saved** data. If you run `docker image ls` again, you should see your image's name. Running `docker run ...` again will put you right back into the same Jupyter server. 

For more information about managing your images, see [official documentation](https://docs.docker.com/reference/cli/docker/image/).

### Making changes to the Docker image

Docker images themselves are immutable, so in order to make changes to the packages included or run additional programs, you will need to build a new image. This is a bit more of an advanced topic, so I would recommend reading [official documentation](https://docs.docker.com/get-started/docker-concepts/building-images/writing-a-dockerfile/) and finding a tutorial online that speaks to you. 

You can modify the Dockerfile provided, or you can make your own. The basic components of a Dockerfile are: pulling a base image (any image available on Docker Hub can function as your base image), and a set of commands to install packages and run commands that build your software. The basic anatomy of this Dockerfile is annotated via comments. I am not by any means an expert on Dockerfiles, and in general I would recommend pulling an existing image that mostly works rather than building an image entirely from scratch.

## Tutorial documents

I did not write the material contained within the Jupyter notebooks provided, though I did translate the Seurat tutorial from its original R markdown format into the Jupyter format. I have linked the original sources within these documents, and I recommend checking out other work by those authors for additional materials. All of the code blocks should run without any modification, but I would encourage modifying parameters or trying the code with new datasets to get a good understanding of how these functions work and the types of analysis you can perform with them. 

Jupyter notebooks themselves are great for trying things out with small datasets, since you can save the outputs and plots in the same document as your code. One limitation is that it can struggle a bit with large datasets or documents with many plots, particularly if the computer you run it on doesn't have much RAM. You can split a project across multiple documents, but you will need to save workspace objects to disk to use them in multiple notebooks.



