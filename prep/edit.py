import json
import csv
import re
import pickle
from collections import Counter

dict = []

with open('words.pkl', 'rb') as f:
    data = pickle.load(f)

with open('chinese_dict.txt') as f:
    lines = f.readlines()

with open('chinese_text.txt') as f:
    text = f.read()


def chars_of(string): return re.findall(r'.', string.lower())

charsCounter = Counter(chars_of(text))

for line in lines:
    parsed = json.loads(line)
    c = parsed['character']
    dict.append("{},{},{}".format(c, charsCounter[c], parsed['pinyin']))

with open('chinese_chars.csv', 'w') as f:  # Just use 'w' mode in 3.x
    for item in dict:
        f.write("%s\n" % item)