from random import randint
import math
import sys
import re

rnd_pair = 0
rnd_colr = 0

mise_pair = 0
mise_colr = 0

colr = {0: "rouge", 1: "noir"}
max_pair = 40

argent = 0
bargent = 0
montant = 0

rpill = []

def roll():
    global max_pair
    rnd_pair = randint(0,max_pair)
    rnd_colr = randint(0,1)
    return [rnd_pair, rnd_colr, -1]

def main():
    global rpill, argent, montant, bargent, gtype
    print "loto roulette!"
    argent = int(re.sub("[^0123456789]", "", str(input("nombre dargent "))))
    bargent = argent
    posb = ("noir", "rouge", "r", "n", "pair", "p", "impair", "i", "roll", " ")
    stop = False
    vrolled = []
    rolled = ["",""]
    line = 0
    winner = False
    while stop is False and argent >= 10:
        choice = raw_input(":#")
        vrolled = roll()
        rpill.append(vrolled)
        rolled[0] = "pair" if vrolled[0] % 2 == 0 else "impair"
        rolled[1] = "noir" if vrolled[1] == 0 else "rouge"
        if choice in posb:
            montant = int(raw_input(":$"))
            if (rolled[1][:1] == choice[:1]) or (rolled[0][:1] == choice[:1]):
                argent += montant
                rpill[line].append(montant)
                winner = True
            elif choice not in ("r", "roll"):
                argent -= montant
                winner = False
            print rolled[0][:1], rolled[1][:1],
            print str(argent), ("+" if winner else "-"), str(montant)
        else: stop = True if (choice.lower() in ("stop", "quit", "q", "s")) else False
        line += 1
    if argent < 10 or bargent > argent: print "Vous avez perdu", str(bargent-argent), "apres",
    elif bargent < argent: print "Vous avez gagner", str(argent-bargent),
    print str(line)

main()