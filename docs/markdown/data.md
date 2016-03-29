### Data

The data of Prague Czech-English Dependency Treebank 2.0 Coref can be found in the `data` directory and follows
the structure of the original PCEDT 2.0 release: sections `00`-`24` containing one gzipped Treex file (`*.treex.gz`)
per document.

The data are stored in the Treex format, which is an application of the Prague Markup Language 
([PML](http://ufal.mff.cuni.cz/jazz/PML/index_en.html); Pajas and Štěpánek, 2008),
a XML-based format designed for linguistic treebank annotations. For the sake of completeness, PML schemata describing 
the structure of the Treex files are enclosed in the `resources` directory.

### How to browse the data

Tree editor [TrEd](http://ufal.mff.cuni.cz/tred) (Pajas and Štěpánek, 2008) can be used to open and browse the data. 
The editor can be downloaded for various platforms from its [home page](http://ufal.mff.cuni.cz/tred).
Please follow the installation instructions specified at the page for your operating system.

After the installation, an extension needs to be installed:

1. Start TrEd.
2. In the top menu, select *Setup -> Manage Extensions...*; a dialog window with a list of installed extensions appears.
3. Click on the button *Get New Extensions*; a dialog window with a list of available (not yet installed) extensions appears.
4. Make sure that at least the extension *EasyTreex* is checked to install (if it is not in the list, it may have already been installed).
5. Click on the button *Install Selected*; the selected extensions get installed.
6. Close all TrEd windows including the main application window and start TrEd again.

Now, TrEd is able to open the data of PCEDT 2.0 Coref, displaying the analytical and tectogrammatical trees
of one English sentence and its Czech translation (4 trees) at once.

In case of troubles with the installation of TrEd or with browsing the data, please contact the authors at `tred at ufal.mff.cuni.cz`.
