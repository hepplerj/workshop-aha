RMD_FILES := $(patsubst %.Rmd, public/%.html ,$(wildcard *.Rmd))
MD_FILES := $(patsubst %.md, public/%.html ,$(wildcard *.md))
INCLUDE_FILES := $(wildcard include/*.html)
LIBS_FILES := $(wildcard libs/*)
IMG_FILES := $(wildcard img/*)

all : public/build $(RMD_FILES) $(MD_FILES)

public/%.html : %.Rmd $(INCLUDE_FILES)
	R --slave -e "set.seed(100);rmarkdown::render('$(<F)', output_dir = 'public')"

public/%.html : %.md $(INCLUDE_FILES)
	R --slave -e "set.seed(100);rmarkdown::render('$(<F)', output_dir = 'public')"

public/lesson-plan-%.docx : lesson-plan-%.md
	pandoc $^ -o $@

public/lesson-plan-%.rtf : lesson-plan-%.md
	pandoc --standalone $^ -o $@

public/lesson-plan-%.md : lesson-plan-%.md
	cp $^ $@

public/build : $(INCLUDE_FILES) $(LIBS_FILES) $(IMG_FILES)
	mkdir -p public/
	cp -r -p libs public/
	cp -r -p img public/
	cp -r -p data public/
	touch public/build

.PHONY : deploy
deploy :
	rsync --progress --delete -avz \
		--exclude='.git' \
		public/* jasonhep@jasonheppler.org:~/public_html/jasonheppler/projects/aha-workshop/

.PHONY : clean
clean :
	rm -f $(HTML_FILES)
	rm -rf public/*
