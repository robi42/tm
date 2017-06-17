TempMunger
==========

FS layout loosely resembles CVAST research group [guidelines][CVAST guidelines].

This project employs a Git submodule setup, consequently:

    git submodule init && git submodule update

App can be run via: 

    bin/run.sh

(This will open a browser window at `localhost:4000` after one minute startup time, at least on macOS.)

Run requirements:
 * Java 8
 * Node 6+

To build app package incl. docs: 

    make install

Build requirements:
 * [JDK] 8
 * [Node] 6+
  * [Yarn] (e.g., `brew install yarn`)
  * [Gulp] CLI (`npm i -g gulp-cli`)
  * [ESDoc] tool (`npm i -g esdoc`)

Note: the project is "dockerized", see `Makefile` and `Dockerfile`s respectively.


[CVAST guidelines]: http://www.cvast.tuwien.ac.at/node/27

[JDK]: http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
[Node]: https://nodejs.org/
[Yarn]: https://yarnpkg.com/
[Gulp]: http://gulpjs.com/
[ESDoc]: https://esdoc.org/
