#!/usr/bin/env python

from lxml import etree
import sys
#filename='/Users/ruben/CODE/VU-sentiment-lexicon-xml/VUSentimentLexicon/EN-lexicon/Sentiment-English-HotelDomain.xml'

root = etree.parse(sys.stdin).getroot()

for element in root.findall('Lexicon/LexicalEntry'):
  ele_lemma = element.findall('Lemma')[0]
  ele_domain = element.findall('Sense/Domain')[0]
  pos = element.get('partOfSpeech','unknown_pos')
  if ele_lemma is not None and ele_domain is not None:
      lemma = ele_lemma.get('writtenForm','').lower()
      aspect = ele_domain.get('aspect','').lower()
      if lemma!='' and aspect!='':
          print lemma.encode('utf-8')+'\t'+pos.encode('utf-8')+'\t'+aspect.encode('utf-8')

