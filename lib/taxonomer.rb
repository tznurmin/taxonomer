# frozen_string_literal: true

# Copyright Toni Nurminen 2023, MIT license

##
# Taxonomer is a text augmentation tool that switches species and strain names.
# It detects taxonomic species names automatically and exchanges them with
# other valid taxonomic species names. Strain names need to be specified and
# are replaced by randomly generated strain names that retain the form of the
# original names (letters are exchanged with other similar letters and numbers
# with other numbers).
class Taxonomer
  
  ##
  # Array of currently available (unused) species names. Use +species_list.last+ if you need to peek which name will be used next.
  attr_reader :species_list
  
  ##
  # Initialises a new Taxonomer instance. 
  #
  # (optional integer) +specseed+: integer value that defines the order of the sampled species names. Defaults to random.
  def initialize(specseed: nil)
    @all_species = {}
    @species_list = []
    @rnd = specseed.nil? ? Random.new : Random.new(specseed)

    File.read(Gem.datadir('taxonomer').nil? ? 'data/taxonomer/species.txt' : "#{Gem.datadir('taxonomer')}/species.txt").split("\n").each do |spec|
      @all_species[spec] = true
      @all_species["#{spec[0]}. #{spec.split(' ')[1]}"] = true
    end
    _regenerate_list
    
    @re = /[A-Z]([a-z]+|\.)\s[a-z]+/
  end
  
  ##
  # Regenerates the species list. Typically there is no reason to call this manually.
  def _regenerate_list
    @species_list = []
    @all_species.keys.each do |s|
      @species_list.push s if s[1] != '.'
    end
    @species_list.shuffle!(random: @rnd)
  end
  
  ##
  # Returns a new species name. The same species name is not seen again until the list of species names is (automatically) repopulated.
  def sample
    _regenerate_list if @species_list.length == 0
    @species_list.pop
  end
  
  ##
  # Helper method that augments the given string by replacing the detected species names and provided strain names.
  #
  # (string) +text+: target text.
  #
  # (optional string array) +wordlist+: an array of strain names that are replaced in the given text. Defaults to empty.
  #
  # (optional boolean) +force_diff+: guarantees that each letter is replaced by a different letter. Defaults to false.
  #
  # (optional string array) +skipped_chars+: a list of characters that are not changed in the strain names. Defaults to Greek letter delta.
  #
  # (optional integer) +rseed+: random seed value that is used to generate new strain names. Defaults to random.
  def obfuscate(text, wordlist = [], force_diff: false, skipped_chars: %w[δ Δ], rseed: nil)
    text = species(text)
    strains(text, wordlist, force_diff: force_diff, skipped_chars: skipped_chars, rseed: rseed)
  end

  ##
  # Augments the text by replacing the given strain names by new strain names. Does not change words that are typically found as part of the strain names, e.g.: isolate, subsp. or genotype.
  #
  # (string) +text+: target text.
  #
  # (string array) +wordlist+: an array of strain names that are replaced in the given text.
  #
  # (optional boolean) +force_diff+: guarantees that each letter is replaced by a different letter. Defaults to false.
  #
  # (optional string array) +skipped_chars+: a list of characters that are not changed in the strain names. Defaults to Greek letter delta.
  #
  # (optional integer) +rseed+: random seed value that is used to generate new strain names. Defaults to random.

  def strains(text, wordlist, force_diff: false, skipped_chars: %w[δ Δ], rseed: nil)

    text = text.split
    strain_rnd = rseed.nil? ? Random.new : Random.new(rseed)
    conserved = %w[strain subsp subspecies isolate pathovar serovar serotype genotype ecotype
                   sequence mutant wild-type complementation complemented pv wt type sp]

    # jump table for characters
    jt = {}

    numbers = %w[0 1 2 3 4 5 6 7 8 9] - skipped_chars
    downcase_v = %w[a e i o u y] - skipped_chars
    downcase_c = %w[a b c d e f g h i j k l m n o p q r s t
                    u v w x y z] - downcase_v - skipped_chars
    upcase_v = downcase_v.map(&:upcase) - skipped_chars
    upcase_c = downcase_c.map(&:upcase) - skipped_chars
    g_downcase = %w[α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ
                    χ ψ ω]- skipped_chars
    g_upcase = %w[Α Β Γ Δ Ε Ζ Η Θ Ι Κ Λ Μ Ν Ξ Ο Π Ρ Σ Τ Υ Φ
                  Χ Ψ Ω]- skipped_chars
    
    [numbers, downcase_v, downcase_c, upcase_v, upcase_c, g_downcase, g_upcase].each do |l|
      temp = l.shuffle(random: strain_rnd)
      if force_diff
        l = temp.dup
        t = l.shift
        l.push t
      end
      l.each do |i|
        jt[i] = temp.shift
      end
    end

    new_words = {}

    wordlist.each do |words|
      temp = ''
      words.split.each do |word|
        if conserved.include? word.gsub('.', '')
          temp += word
        else
          word.split('').each do |c|
            temp += !jt[c].nil? ? jt[c] : c
          end
        end
        temp += ' '
      end
      temp.strip!
      new_words[words] = temp
    end

    text = text.join ' '

    new_words.each do |w, r|
      text.gsub!(Regexp.new("\\b#{w}\\b"), r)
    end
    text
  end

  ##
  # Changes the detected taxonomic species names in target +text+ into new. Abbreviated species names are also detected and changed accordingly (e.g. E. coli). 
  # 
  # (string) +text+: target text.
  def species(text)
    matches = {}
    text.enum_for(:scan, @re).map do
      matches[Regexp.last_match.to_s] = true
    end

    # verified species names
    verified = {}

    # verify candidate species names from matches
    matches.each_key do |candidate|
      unless @all_species[candidate].nil?
        if candidate[1] == '.'
          verified[candidate] = true unless verified[candidate]
        else
          verified[candidate] = true
          verified["#{candidate[0]}. #{candidate.split(' ')[1]}"] = candidate
        end
      end
    end

    # generate new species names
    # for the verified species names (full names only)
    verified.each_key do |s|
      next if s[1] == '.'

      new_species = sample
      verified[s] = new_species
      verified["#{s[0]}. #{s.split(' ')[1]}"] = "#{new_species[0]}. #{new_species.split(' ')[1]}"
    end

    # find all orphaned abbreviated names (no full-form present)
    verified.each_key do |s|
      next if s[1] != '.'
      next if verified[s] != true

      new_species = sample
      verified[s] = "#{new_species[0]}. #{new_species.split(' ')[1]}"
    end

    verified.each do |s, t|
      text.gsub!(s, t)
    end
    text
  end
end
