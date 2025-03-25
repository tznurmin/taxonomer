# Taxonomer
Taxonomer is a text augmentation tool that helps prevent machine learning models from overfitting to important but repetitive content in NLP examples that use biological texts as source material. Taxonomer targets taxonomic species names and strain names by either switching them into other valid taxonomic names automatically or by scrambling defined strain names from the text.

This work implements a part of a data curation pipeline which we are in the process of publishing. More specifically, we found that applying this augmentation method works as a general augmentation strategy for biological texts and helps the models to generalise.

The use is simple. Use augment method with a list of strain names to apply both augmentations to the given text:

````ruby
tx = Taxonomer.new
tx.augment("E. coli is a typical abbreviation for Escherichia coli in scientific literature. However, not all E. coli are the same and there are many different strains to choose from, such as K-12, DH5α and Clifton wild-type. In particular, K-12 and DH5α are very popular E. coli laboratory strains.", ["K-12", "DH5α", "Clifton wild-type"])

# => "H. abietis is a typical abbreviation for Hylobius abietis in scientific literature. However, not all H. abietis are the same and there are many different strains to choose from, such as V-46, ZK2φ and Jlasjim wild-type. In particular, V-46 and ZK2φ are very popular H. abietis laboratory strains."
````


Alternatively, you can use the species method to switch only the species names:

````ruby
tx = Taxonomer.new
tx.species("E. coli is a typical abbreviation for Escherichia coli in scientific literature. However, not all E. coli are the same and there are many different strains to choose from, such as K-12, DH5α and Clifton wild-type. In particular, K-12 and DH5α are very popular E. coli laboratory strains.")

# => "A. parviflora is a typical abbreviation for Agave parviflora in scientific literature. However, not all A. parviflora are the same and there are many different strains to choose from, such as K-12, DH5α and Clifton wild-type. In particular, K-12 and DH5α are very popular A. parviflora laboratory strains."
````

Or strains method to scramble the strain names:

````ruby
tx = Taxonomer.new
tx.strains("E. coli is a typical abbreviation for Escherichia coli in scientific literature. However, not all E. coli are the same and there are many different strains to choose from, such as K-12, DH5α and Clifton wild-type. In particular, K-12 and DH5α are very popular E. coli laboratory strains.", ["K-12", "DH5α", "Clifton wild-type"])

# => "E. coli is a typical abbreviation for Escherichia coli in scientific literature. However, not all E. coli are the same and there are many different strains to choose from, such as S-01, VJ8ε and Trawveh wild-type. In particular, S-01 and VJ8ε are very popular E. coli laboratory strains."
````

# License information
This tool uses a [modified version](https://github.com/tznurmin/taxonomer/blob/main/data/taxonomer/species.txt) of a [species file](https://ftp.uniprot.org/pub/databases/uniprot/knowledgebase/complete/docs/speclist.txt) named 'Controlled vocabulary of species' and published by UniProt Consortium.

The work is used under the following license:
Copyrighted by the UniProt Consortium, see https://www.uniprot.org/terms
Distributed under the Creative Commons Attribution (CC BY 4.0) License
