USER=jdoe
HOST=example.net
LOGIN=$(USER)@$(HOST)

define DOCKER_CLEANUP
	docker ps --filter status=exited -q | xargs docker rm -v 2>&1 >/dev/null; echo
	docker images --filter dangling=true -q | xargs docker rmi 2>&1 >/dev/null; echo
	ssh $(LOGIN) "docker ps --filter status=exited -q | xargs --no-run-if-empty docker rm -v 2>&1 >/dev/null; echo" 2>&1 >/dev/null
	ssh $(LOGIN) "docker images --filter dangling=true -q | xargs --no-run-if-empty docker rmi 2>&1 >/dev/null; echo" 2>&1 >/dev/null
endef

all:
	@echo Goals: install build_backend build_frontend build_thesis build_poster deploy_app deploy_backend deploy_frontend deploy_thesis deploy_poster presentation build_presentation deploy_presentation


build_backend:
	cd src/backend && ./gradlew clean build #-x test
	cp src/backend/build/libs/temp-munger.jar bin/
	rm -rf dokka && mv src/backend/build/dokka dokka
	cp src/backend/build/asciidoc/html5/index.html doc/api.html

build_frontend:
	cd src/frontend && yarn install && gulp esdoc
	rm -rf esdoc && mv src/frontend/doc esdoc

build_thesis:
	cd doc/source/thesis && ./build-thesis.sh
	mv doc/source/thesis/thesis.pdf doc/
	cd doc && gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress "-sOutputFile=thesis_embed.pdf" thesis.pdf

build_poster:
	cd doc/source/poster && pdflatex INF_Poster.tex; bibtex INF_Poster.tex; pdflatex INF_Poster.tex; pdflatex INF_Poster.tex
	mv doc/source/poster/INF_Poster.pdf doc/poster.pdf
	cd doc && gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress "-sOutputFile=poster_embed.pdf" poster.pdf

install: build_backend build_frontend #build_thesis # Building thesis.pdf requires installed LaTex distro.


deploy_backend:
	cd src/backend && ./gradlew clean buildDocker #-x test -x asciidoctor
	ssh $(LOGIN) "docker pull jdoe/tm-be"
	ssh $(LOGIN) "docker stop $$(ssh $(LOGIN) "docker ps --format '{{.ID}}: {{.Command}}' | grep java | sed s/:.*//")"
	ssh $(LOGIN) "docker run -p 8888:8888 -d --restart always jdoe/tm-be:latest"
	$(call DOCKER_CLEANUP)

deploy_frontend:
	docker build -t tm-fe src/frontend
	docker tag $$(docker images -q tm-fe) jdoe/tm-fe:latest
	docker push jdoe/tm-fe
	ssh $(LOGIN) "docker pull jdoe/tm-fe"
	ssh $(LOGIN) "docker stop $$(ssh $(LOGIN) "docker ps --format '{{.ID}}: {{.Command}}' | grep npm | sed s/:.*//")"
	ssh $(LOGIN) "docker run -p 8000:8000 -d --restart always jdoe/tm-fe:latest"
	$(call DOCKER_CLEANUP)

deploy_app: deploy_backend deploy_frontend

deploy_thesis: build_thesis
	rsync -avzhP doc/thesis_embed.pdf $(LOGIN):/var/www/tm/thesis.pdf

deploy_poster: build_poster
	rsync -avzhP doc/poster_embed.pdf $(LOGIN):/var/www/tm/poster.pdf


presentation: # https://jupyter.org/install.html
	cd doc/source/presentation && jupyter nbconvert Presentation.ipynb --to slides --post serve

build_presentation:
	cd doc/source/presentation && jupyter nbconvert Presentation.ipynb --to slides

deploy_presentation: build_presentation
	rsync -avzhP doc/source/presentation/Presentation.slides.html $(LOGIN):/var/www/tm/presentation/index.html
	rsync -avzhP doc/source/presentation/custom.css $(LOGIN):/var/www/tm/presentation/custom.css
	rsync -avzhP doc/source/presentation/reveal.js $(LOGIN):/var/www/tm/presentation/
