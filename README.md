# Artificial Love for iOS
Poems are generated by a LSTM running on Metal and Accelerate.
Code is borrowed from [Infinite Monkeys](https://github.com/craigomac/InfiniteMonkeys/tree/master/InfiniteMonkeys)

Neural Network is an LSTM in keras trained on a Haiku database for 10 hours. The network is reconstructed on the device using
[BraincoreiOS](https://github.com/aleph7/BrainCore). From here a seed sentence starts the process of text generation based on the 
weights that the network has learned from the training data. The result is the reconstruction of a phrases from the haiku database.


![alt text](https://github.com/tothepoweroftom/ArtificialLove/Haiku4u/demo.gif)

