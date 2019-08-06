# Amin Babar
# 09/30/18
# Version: ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux]
# Text Generator using Markov Chains:
# This program takes an input file, and generates output based on the frequency
# of words in the file. It implements the functions to_s, inspect,
# generate_text(text_length), generate_sentence and each. The program uses hash
# to store the trigrams for the Markov Chain.



class MarkovChainTextGenerator
    include Enumerable

    def initialize(input_file)

        @trigrams = Hash.new
        @sentence_starters = []
        @end_of_sentence_punctutation = 0
        file = File.read(input_file)
        @array_words = file.split

        i = 0

        # Files that only have 2 words or less are not handled by this program.
        # For files greater than size 2, all the two consecutive words are
        # turned into keys for a hash. The value correspoding to each key is
        # an array of words that follows the 2 lettered key. This way all the
        # trigrams for the input file are stored in the hash during 
        # initialization.
        if @array_words.length > 2

            until i == (@array_words.length - 2) do

            key = "#{@array_words[i]} #{@array_words[i + 1]}"
            value = @array_words[i + 2]

            # keeps track of all the keys that start with a capital word for
            # generate_sentence
            if key.split[0][0] =~ /[A-Z]/
                @sentence_starters << key
            end

            # Turns @end_of_sentence_punctuation true even if there is a single
            # word followed by end of sentence punctuation. Used in 
            # generate_sentence
            if (@end_of_sentence_punctutation == 0) and (@array_words[i + 2][-1] =~ /[.|!|?]/)
                @end_of_sentence_punctutation = 1
            end

            if @trigrams[key] == nil
                @trigrams[key] = [value]

            else
                @trigrams[key] = @trigrams[key] << value
            end

            i += 1

            end
        end
    end

    # generates a human friendly string describing the object
    def to_s
        return "This is a random text generator!"
    end

    # returns a string describing the object
    def inspect
        return "This is a random text generator!"
    end

    # generates text_length number of words based on the probabilities of a
    # following word from an input file. The starting two words are chosen
    # randomly. Does not accept input files with less than 3 words.
    def generate_text(text_length)

        if @array_words.length < 3
            return "Length of the input_file is too small to produce trigrams"

        # if the input text_length is greater than 0 and not a string,
        # text_length number of words are generated based on the probabilities
        # in the markov chain. If the length of the text to be produced is one,
        # a single word is chosen by randomly sampling the values in the hash
        # (which are arrays) and then sampling the arrays. If the size of the
        # text to be produced is greater than 1, a random key is chosen first.
        # This key corresponds to the first 2 words in the string.
        # based on the random key the corresponding array is sampled to result
        # in a single word that could have followed the 2 preceding words. This
        # word is attached to the end of the key while the first word from the
        # key is removed. Based on this new key, another array is sampled for a
        # following_word. If the key does not exist in the hash, a random key is
        # sampled from all the keys in the array. This process is repeated until
        # we have the right number of words for the string we need to return.
        elsif text_length.to_s =~ /[1-9]/ and text_length.class == Integer

            if text_length == 1
                return @trigrams.values.sample.sample
            end

            key = @trigrams.keys.sample
            string = key
            i = 0
            until i == text_length - 2 do

                if @trigrams[key] == nil
                    key = @trigrams.keys.sample
                end

                following_word = @trigrams[key].sample
                string += " #{following_word}"
                key = "#{key.split[1]} #{following_word}"
                i += 1
            end

        # A wrong input to the generate_text function result in an error message.
        else
            return "Enter a positive integer greater than 0 for generate_text()"
        end

        return string
    end

    # This method generates a complete sentence based on the input file. The
    # sentence starts with a capital letter and ends with end of sentence
    # puntutation like "?", ".", "!". Does not run for input files with size
    # less than 3.
    def generate_sentence

        if @array_words.length < 3
            return "Length of the input_file is too small to produce trigrams"

        # This function results in an error message if there are no capital
        # words or no end of sentence punctutation in the input file.
        elsif (@end_of_sentence_punctutation == 0) or (@sentence_starters.length == 0)
            return "End of sentence punctuation or sentence starters or both not found in the text!"
        end

        # Based on a random key from the sentence_starters array, which contains
        # all the keys for the hash that start with a capital word a new key is
        # randomly chosen. Words that follow the key are randomly generated
        # based on probilitity. As soon as an end of sentence punctuation is
        # seen the process of generating words that follow a constantly chaging
        # key stops and the sentence is output. Uses the same process to
        # generate following words as the generate_text method. If end of
        # sentence punctutation is found in the starting key, words until the
        # end of sentence punctuation are returned. If the only end of sentence
        # punctuation is found in the first 2 words of the sentence, the program
        # will return an error message.
        key = @sentence_starters.sample

        if key.split[0][-1] =~ /[.|!|?]/
            return key.split[0]
        elsif key.split[1][-1] =~ /[.|!|?]/
            return key
        end

        sentence = key
        until sentence[-1] =~ /[!|.|?]/ do
            if @trigrams[key] == nil
                key = @trigrams.keys.sample
            end

            following_word = @trigrams[key].sample
            sentence += " #{following_word}"
            key = "#{key.split[1]} #{following_word}"
            
        end

        return sentence
    end

    # Yields each word in a sentence generated by the method generate_sentence
    # CITE: Syntax for 0.upto(sentence.split.length - 1) do |x| copied from
    # stack overflow.
    def each 
        if @array_words.length < 3
            return "Length of the input_file is too small to produce trigrams"
        end
        
        sentence = generate_sentence
        0.upto(sentence.split.length - 1) do |x|
        yield sentence.split[x]
        end
    return sentence
    end

end