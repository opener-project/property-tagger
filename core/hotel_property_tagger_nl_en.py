#!/usr/bin/env python

import sys
import argparse

import codecs
import os

this_folder = os.path.dirname(os.path.realpath(__file__))

# This updates the load path to ensure that the local site-packages directory
# can be used to load packages (e.g. a locally installed copy of lxml).
sys.path.append(os.path.join(this_folder, 'site-packages/pre_build'))
sys.path.append(os.path.join(this_folder, 'site-packages/pre_install'))

from VUKafParserPy import KafParser
from lxml import etree
from collections import defaultdict

__desc='VUA property tagger'
__last_edited='20may2014'
__version='1.0'

###
__module_dir = os.path.dirname(__file__)
max_ngram = 1
verbose = False
##


########################################
## Format of the file:
#lemma pos aspect
#lemma pos aspect
########################################
def loadAspects(my_lang,this_file=None):
  my_aspects = {}
  if this_file is not None:
    aspects_filename = this_file
  else:
    filename = "{0}.txt".format(my_lang)
    print>>sys.stderr, "filename thingy",filename
    print>>sys.stderr, "path thingy",arguments.path
    aspects_filename = os.path.join(arguments.path,filename)

  if not os.path.exists(aspects_filename):
    print>>sys.stderr,'ERROR: file with aspects for the language',my_lang,'not found in',aspects_filename
  else:
    fic = codecs.open(aspects_filename,'r','utf-8')
    for line in fic:
      fields = line.strip().split('\t')
      lemma,pos,aspect = fields
      my_aspects[lemma] = aspect
    fic.close()
  return aspects_filename, my_aspects
########################################



###### MAIN ########

argument_parser = argparse.ArgumentParser(description='Tags a text with polarities at lemma level')
argument_parser.add_argument("--no-time",action="store_false", default=True, dest="my_time_stamp",help="For not including timestamp in header")
argument_parser.add_argument("--lexicon", action="store", default=None, dest="lexicon", help="Force to use this lexicon")
argument_parser.add_argument("--path", action="store", default=None, dest="path", help="Set the path where the property aspects are found.")

arguments = argument_parser.parse_args()

if not sys.stdin.isatty():
    ## READING FROM A PIPE
    pass
else:
    print>>sys.stderr,'Input stream required.'
    print>>sys.stderr,'Example usage: cat myUTF8file.kaf.xml |',sys.argv[0]
    print>>sys.stderr,sys.argv[0]+' -h  for help'
    sys.exit(-1)


## Load the tree and the list of terms with the id
my_data = []
try:
  my_kaf_tree = KafParser(sys.stdin)
except Exception as e:
  print>>sys.stdout,'Error parsing input. Input is required to be KAF'
  print>>sys.stdout,str(e)
  sys.exit(2)


## Get language from the KAF file
my_lang  = my_kaf_tree.getLanguage()

my_aspects_filename = my_aspects = None
if arguments.lexicon is None:
  if my_lang not in ['nl','en','de','fr','it','es']:
    print>>sys.stdout,'Error in the language specified in your KAF. The language is ',my_lang,' and possible values for this module '
    print>>sys.stdout,'are nl for Dutch ,en for English, es Spanish, fr French, it Italian or de German'
    sys.exit(1)

  my_aspects_filename, my_aspects = loadAspects(my_lang)
else:
  my_aspects_filename, my_aspects = loadAspects(my_lang,this_file=arguments.lexicon)

if verbose:
  print>>sys.stderr,'Loaded ',len(my_aspects),'aspects from',my_aspects_filename


for term in my_kaf_tree.getTerms():
    my_data.append((term.getLemma(),term.getId()))
if verbose: print>>sys.stderr,'Number of terms in the kaf file:',len(my_data)


current_token = found = 0
uniq_aspects = defaultdict(list)
while current_token < len(my_data):
    for tam_ngram in range(1,max_ngram+1):
        # Build an n-gram of size tam_ngram and beginning in current_token
        if current_token + tam_ngram <=  len(my_data):
            ngram = ' '.join(lemma for lemma,_ in my_data[current_token:current_token+tam_ngram])
            aspect = my_aspects.get(ngram,None)
            if aspect is not None:
                list_of_ids = [id for _,id in my_data[current_token:current_token+tam_ngram]]
                uniq_aspects[aspect].append((list_of_ids,ngram))
    current_token += 1


## Code for generating the propery layer included in the Parser
for aspect, list_of_lists in uniq_aspects.items():
  for list_of_ids, str_text in list_of_lists:
    my_kaf_tree.add_property(aspect,list_of_ids,str_text)

my_kaf_tree.addLinguisticProcessor(__desc,__last_edited+'_'+__version,'features', arguments.my_time_stamp)
my_kaf_tree.saveToFile(sys.stdout)






