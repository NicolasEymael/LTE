# LTE
project to simulate an LTE system in Data Communication

cada documento fala uma coisa e acho que dependendo dos releases com o passar dos anos foi mudando algumas features e tals, mas aqui tem alguns documentos:
  https://www.etsi.org/deliver/etsi_ts/136200_136299/136201/08.03.00_60/ts_136201v080300p.pdf
  https://www.nxp.com/docs/en/white-paper/3GPPEVOLUTIONWP.pdf
  https://bwn.ece.gatech.edu/ltea/papers/LTE_overview.pdf
  https://literature.cdn.keysight.com/litweb/pdf/5989-8139EN.pdf?id=1431418

a ideia inicial é simular só o downlink (que usa OFDM) e ignorar o uplink (que usa SC-FDMA) pra tentar facilitar as coisas

o LTE tem bastaaante coisa e é bem complexo, mas a gente nao precisa necessariamente implementar tudo

o nazar falou que LTE é mais dificil que 802.11 entao provavelmente ele vai relevar se a gente implementar algo "parecido"

basicamente o fluxo é:

bits --> coding --> modulation --> MIMO --> OFDM --> (meio ruidoso) --> recepção do sinal e blablabla

coding:
  "The channel coding scheme for transport blocks in LTE is Turbo Coding as for UTRA, with a coding rate of R=1/3, two
8-state constituent encoders and a contention-free Quadratic Permutation Polynomial (QPP) turbo code internal
interleaver. Trellis termination is used for the turbo coding. Before the turbo coding, transport blocks are segmented
into byte aligned segments with a maximum information block size of 6144 bits. Error detection is supported by the use
of 24 bit CRC."

puta que pariu eu entendi foi nada, só entendi que é turbo coding de razão 1/3 e tem uns documentos pra ajudar
https://www.etsi.org/deliver/etsi_ts/136200_136299/136212/10.00.00_60/ts_136212v100000p.pdf
http://www.qtc.jp/3GPP/Specs/36212-800.pdf

modulation:
  "The modulation schemes supported in the downlink and uplink are QPSK, 16QAM and 64QAM."
  
ta esse é de boas se pa, parecido com um dos trabalhinhos
  
MIMO:
    "Transmission with multiple input and multiple output antennas (MIMO) are supported with configurations in the
downlink with two or four transmit antennas and two or four receive antennas, which allow for multi-layer
transmissions with up to four streams."

é aquele lance de usar varias antenas pra aumentar a taxa de dados loucamente e ainda to pensando em como fazer

OFDM:
aquela coisa que usa prefixo ciclico e tals que caiu na prova e acho que tem uma funçao pra isso no matlab

deve ter função pra colocar ruido no matlab e a recepção é basicamente o contrario da transmissão então eras isso o trabalho.

PLOTAR GRAFICOS BER PARA DIFERENTES VARIAÇOES DO SISTEMA
    
