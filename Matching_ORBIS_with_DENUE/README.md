# Matching ORBIS with DENUE

## Data: Geographical Zone Recoding

- **1-1-data_cleaning_geographical_locations_python.ipynb**: The main objective of this code is to get all the unique tuples of the form (`entity`, `municipality`, `postcode`) from `zip_codes`, `orbis` and `denue`. The data of these tuples contain is clean from accents, punctuation and any irregularities. 

## Data: Cleaning and structuring the data

- **1-2-1-data_cleaning_python_denue_version_both.ipynb**:  This file performs these operations in DENUE's database: Recode geographical location and keep firms that provide it. Keep the firms with at least one business name associated (razon social) or big companies (more than 50 employees). Reshape the dataset such that each observation corresponds to a single possible name of a firm in its location. Remove 'stopwords'. 
- **1-2-2-data_cleaning_python_denue_version_both_alternative.ipynb**: Same as 1-2-1, but for a bigger data set with firms with more than 5 workers. 
- **1-2-3-data_cleaning_python_orbis_for_denue_merge.ipynb**: This file performs these operations in ORBIS's database: Recode geographical location. Reshape the dataset such that each observation corresponds to a single possible name of a firm in its location. Remove 'stopwords'. 

## Processing: Matching the firms

### General Instructions

The goal is to obtain the all possible firms in DENUE that could be a match for a firm in ORBIS. This will be achieved by implementing two **A**lgorithms: 

1. **TF-IDF 2-3 ngrams Cosine Similarity**: First, we split the words of each sentence in *ngrams* (little pieces of 2 to 3 letters). Then, we apply the *Term Frequency Inverse Document Frequency*. TF counts how many times a ngram appears in a firm's name $\text{TF} = \frac{\text{Number of times ngram appears}}{\text{Total ngrams in firm's name}}$. IDF weights how important the ngram across all firm names. This is done by calculating $IDF = \log(\frac{\text{Number of firms}}{\text{Number of firms with that ngram in name}})$.  Then, we decompose each firm's name into a vector with all possible ngram across all firm names and multiply two sparse matrices of all the firms in the base dataframe in the left with another matrix in the right with all the firms in the matching dataframe. This we'll make faster the dot product of every vector for each firm's name (TF*IDF).  This algorithm returns a pseudo cosine distance, we'll call it score, between the two vectors and gives us a number between 0 and 1, the closer to 1 the better the match we'll be. This is the most accurate algorithm out of the two of them. This [link](https://janav.wordpress.com/2013/10/27/tf-idf-and-cosine-similarity/) and this [one](https://bergvca.github.io/2017/10/14/super-fast-string-matching.html) are good introductions to the algorithm. 
2. **Rapidfuzz**: On the other side, we need a robustness check of the **TF-IDF** algorithm, so, we apply a second algorithm. We selected the method called *sort_token_ratio*, which gives us the Levenshtein's similarity score derived directly from the usual Levenshtein's distance. The difference is that we first sort the words of a firm's name alphabetically, then, we apply the Levenshtein's distance. This algorithm is less accurate, so we tolerate less difference between firm names than with the principal one. 

Then, we apply these algorithms to two **V**ersions of DENUE: 

1. **DENUE**: This database takes into account the firms with more than 50 employees or the ones that have a business name registered (razon social). 
2. **DENUE_alternative**: The same as the one above, but, instead of 50 employees, it takes into account the firms that have more than 5 employees. 

Finally, these algorithms will control by different criteria of **G**eographical zones and firm's size when matching the firms' names in the base data set and the matching data set: 

1. Both datasets controlling by entity and municipality. 
2. Controlling ORBIS by entity and municipality and DENUE by entity adding all the big companies (more than 5 or 50 employees depending on the DENUE's version). 
3. Controlling ORBIS by entity and municipality and not controlling by anything in DENUE (entire data set version). 
4. ORBIS companies that don't specify a geographical zone can't be controlled by anything and entire DENUE's data set. 

### Steps and their associated files

So, the steps associated with this task will follow this nomenclature according to the General Information presented above: 

$$\begin{matrix} A & V & G \\ 1 & 1 & 1 \\ 2 & 2 & 2 \\ & & 3 \\ & & 4 \end{matrix}$$

So, the files presented below are $\forall a \in A \; \forall v \in V \; \forall g \in G$, the files which execute the corresponding name similarity algorithms:

1. File **2-1-1-1-tf_idf_both_entity_municipality.ipynb**. 
2. File **2-1-1-2-tf_idf_orbis_entity_municipality_denue_entity_big_companies.ipynb**. 
3. File **2-1-1-3-tf_idf_orbis_entity_municipality_denue.ipynb**. 
4. File **2-1-1-4-tf_idf_orbis_no_geo_denue.ipynb**. 
5. File **2-1-2-1-tf_idf_both_entity_municipality_alternative.ipynb**. 
6. File **2-1-2-2-tf_idf_orbis_entity_municipality_denue_entity_big_companies_alternative.ipynb**. 
7. File **2-1-2-3-tf_idf_orbis_entity_municipality_denue_alternative.ipynb**. 
8. File **2-1-2-4-td_idf_orbis_no_geo_denue_alternative.ipynb**. 
9. File **2-2-1-1-rapidfuzz_both_entity_municipality.ipynb**. 
10. File **2-2-1-2-rapidfuzz_orbis_entity_municipality_denue_entity_big_companies.ipynb**. 
11. File **2-2-1-3-rapidfuzz_orbis_entity_municipality_denue.ipynb**. 
12. File **2-2-1-4-rapidfuzz_orbis_no_geo_denue.ipynb**. 
13. File **2-2-2-1-rapidfuzz_both_entity_municipality_alternative.ipynb**. 
14. File **2-2-2-2-rapidfuzz_orbis_entity_municipality_denue_entity_big_companies_alternative.ipynb**. 
15. File **2-2-2-3-rapidfuzz_orbis_entity_municipality_denue_alternative.ipynb**
16. File **2-2-2-4-rapidfuzz_orbis_no_geo_denue_alternative.ipynb**. 

After all this files are executed, the results are a set of files with their corresponding matches by algorithm, version and respective controls. 

# Processing: Join the matches

- **3-1-concatenating_and_filtering_matches.ipynb**: This file concatenates all the files from step 2 $\forall a \in A \; \forall v \in V \; \forall g \in G$. 

- **3-2-summary_statistics_of_the_algorithms.ipynb**: This files gives a summary of the performance of both algorithms controlling by: 

  - Algorithm. 
  - Entity. 
  - Number of workers. 

  Also, note that this statistics contemplate the firms that didn't match with any firm in every selection of version and geographic control. 
