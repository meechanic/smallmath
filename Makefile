.PHONY: prepare-diafiles prepare-dotfiles prepare-gnuplotfiles ps pdf dvi rtf ooo html pdf-archive html-archive install-pdf install-ps install-dvi install-rtf install-pdf-archive install-html-archive clean

DOCNAME := me_mat_inzh
TARGETDIR := .

dotfiles = $(wildcard *.dot)
diafiles = $(wildcard *.dia)
latexfiles = $(wildcard *.tex)
dvifiles = $(patsubst %.tex,%.dvi,$(wildcard $(latexfiles)))
psfiles = $(patsubst %.tex,%.ps,$(wildcard $(latexfiles)))
pdffiles = $(patsubst %.tex,%.pdf,$(wildcard $(latexfiles)))
rtffiles = $(patsubst %.tex,%.rtf,$(wildcard $(latexfiles)))
gnuplotfiles = $(wildcard *.gnuplot)
GNUPLOT_DATADIR = $(gnuplot.files)
gnupl_datafiles = $(wildcard $(GNUPLOT_DATADIR)*)
PDFNAME=$(DOCNAME)"-pdf"
HTMLNAME=$(DOCNAME)"-html"
OOONAME=$(DOCNAME)"-ooo"

pdf-archive: pdf
	tar -czvf $(PDFNAME)".tgz" $(pdffiles)

html-archive: html
	tar -czvf $(HTMLNAME)".tgz" $(HTMLNAME)

ps: dvi
	for NAME in $(dvifiles);\
	do NAME2=`echo $$NAME | sed -n 's/\(.*\)\(\.dvi\)/\1/p'`;\
	dvips $$NAME2".dvi";\
	done

pdf: dvi
	for NAME in $(dvifiles);\
	do NAME2=`echo $$NAME | sed -n 's/\(.*\)\(\.dvi\)/\1/p'`;\
	dvipdfm $$NAME2".dvi" ;\
	done

dvi: prepare-dotfiles prepare-diafiles prepare-gnuplotfiles $(latexfiles);
	for NAME in $(latexfiles);\
	do latex $$NAME #for making index of bibliography, stupid method;\
	latex $$NAME;\
	done

rtf: dvi
	for NAME in $(latexfiles);\
	do NAME2=`echo $$NAME | sed -n 's/\(.*\)\(\.tex\)/\1/p'`;\
        cp $$NAME2".tex" $$NAME2".tex";\
	latex2rtf -F -M12 -a $$NAME2".aux" -o $$NAME2".rtf" $$NAME2;\
        rm $$NAME2".tex";\
	done

html: dvi
	rm -rf $(HTMLNAME);\
	mkdir $(HTMLNAME);\
	for NAME in $(latexfiles);\
	do htlatex $$NAME "html,word" "" -d$(HTMLNAME)"/";\
	done

ooo: dvi
	mkdir $(OOONAME);\
	for NAME in $(latexfiles);\
	do htlatex $$NAME "xhtml,ooffice" "ooffice/! -cmozhtf" "-d$(OOONAME)"/" -coo -cvalidate";\
	done

prepare-dotfiles: $(dotfiles)
	for NAME in $^;\
	do NAME2=`echo $$NAME | sed -n 's/\(.*\)\(\.dot\)/\1/p'`;\
	cat $$NAME | dot -Tsvg -o"images/"$$NAME2".svg";\
	inkscape "images/"$$NAME2".svg" --export-eps="images/"$$NAME2".eps";\
	rm "images/"$$NAME2".svg";\
	done

prepare-diafiles: $(diafiles)
	for NAME in $^;\
	do NAME2=`echo $$NAME | sed -n 's/\(.*\)\(\.dia\)/\1/p'`;\
	dia $$NAME -e "images/"$$NAME2".svg";\
        inkscape "images/"$$NAME2".svg" --export-png="images/"$$NAME2".png";\
	inkscape "images/"$$NAME2".svg" --export-eps="images/"$$NAME2".eps";\
	#rm "images/"$$NAME2".svg";\
	done

prepare-gnuplotfiles: $(gnuplotfiles) $(gnupl_datafiles)
	for NAME in $(gnuplotfiles);\
	do NAME2=`echo $$NAME | sed -n 's/\(.*\)\(\.gnuplot\)/\1/p'`;\
	cat $$NAME | pgnuplot | gnuplot  > "images/"$$NAME2".eps";\
	done

install-ps: ps
	mkdir -p $(TARGETDIR);\
	cp $(psfiles) $(TARGETDIR)

install-pdf: pdf
	mkdir -p $(TARGETDIR);\
	cp $(pdffiles) $(TARGETDIR)

install-dvi: dvi
	mkdir -p $(TARGETDIR);\
	cp $(dvifiles) $(TARGETDIR)

install-rtf: rtf
	mkdir -p $(TARGETDIR);\
	cp $(rtffiles) $(TARGETDIR)

install-pdf-archive: pdf-archive
	mkdir -p $(TARGETDIR);\
	cp $(PDFNAME)".tgz" $(TARGETDIR)

install-html-archive: html-archive
	mkdir -p $(TARGETDIR);\
	cp $(HTMLNAME)".tgz" $(TARGETDIR)

clean:
	rm -rf *.aux *.log *.toc *.html *.4ct *.4tc *.lg *.xref *.css *.tmp *.idv *.4og *.png *.idx *.dvi *.pdf *.out *.ps *.odt *.iml *.tgz *~ $(DOCNAME)-html $(DOCNAME)-ooo *.rtf
