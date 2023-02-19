require 'taxonomer'

describe 'Taxonomer' do
  
  before do
    @tx = Taxonomer.new
  end
  
  context 'strains' do
    
    it 'Is possible to define random seed for strain name scrambling' do
      [true, false].each do |force|
        text = "E. coli strains K12 and Nissle 1917 are useful laboratory strains while O157:H7 and O26 are pathogenic. Therefore, it is advisable to stick with the usage of K12 and Nissle 1917 strains in basic laboratory experiments."
        tx = Taxonomer.new
        r1 = tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force, rseed: 42)
        tx = Taxonomer.new
        r2 = tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force, rseed: 42)
        tx = Taxonomer.new
        r3 = tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force, rseed: 43)
        
        expect(r1 == r2).to eq(true)
        expect(r1 == r3).to eq(false)
        
        r4 = @tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force, rseed: 44)
        r5 = @tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force, rseed: 44)
        expect(r4 == r5).to eq(true)
      end
    end
    
    it 'Uses a new random seed for scrambling the names each time if rseed is not defined' do
      [true, false].each do |force|
        text = "E. coli strains K12 and Nissle 1917 are useful laboratory strains while O157:H7 and O26 are pathogenic. Therefore, it is advisable to stick with the usage of K12 and Nissle 1917 strains in basic laboratory experiments."
        tx = Taxonomer.new
        r1 = tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force, rseed: 42)
        tx = Taxonomer.new
        r2 = tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force)
        tx = Taxonomer.new
        r3 = tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force)
        
        expect(r1 == r2).to eq(false)
        expect(r2 == r3).to eq(false)
        expect(r1 == r3).to eq(false)
        
        r4 = @tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force)
        r5 = @tx.strains(text.dup, ['Nissle 1917', 'K12', 'O157:H7', 'O26'], force_diff: force)
        
        expect(r4 == r5).to eq(false)
      end
    end
    
    it 'Is possible to ensure no original strain names are found' do
      text = "Qualitatively, the strain Q was found to be the least reactive."
      500.times do
        text2 = @tx.strains(text.dup, ['Q'], force_diff: true).split(' ')
        expect(text2[3] != 'Q').to be(true)
        text2[3] = 'Q'
        expect(text2.join(' ') == text).to be(true)
      end
    end
    
    it 'Randomises strain names so that strain names can stay the same' do
      text = "Qualitatively, the strain Q was found to be the least reactive."
      found = false
      10000.times do
        text2 = @tx.strains(text.dup, ['Q']).split(' ')
        found = text2[3] == 'Q' unless found
        break if found
      end
      expect(found).to be(true)
    end
    
    it 'Conserves delta as default' do
      
      st = %w[5 β I A b]
      
      (st.length+1).times do |i|
        strain = st.dup.insert(i, 'δ').join('')
        text = "Strain #{strain} is most commonly found from example texts."
        expect(@tx.strains(text.dup, [strain], force_diff: true).split(' ')[1].split('')[i]).to eq('δ')
        expect(@tx.strains(text.dup, [strain]).split(' ')[1].split('')[i]).to eq('δ')
        
        strain = st.dup.insert(i, 'Δ').join('')
        text = "Strain #{strain} is most commonly found from example texts."
        expect(@tx.strains(text.dup, [strain], force_diff: true).split(' ')[1].split('')[i]).to eq('Δ')
        expect(@tx.strains(text.dup, [strain]).split(' ')[1].split('')[i]).to eq('Δ')
      end
    end
    
    it 'Skips the skipped characters when strain names are scrambled' do
      chars = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ χ ψ ω]
      chars = chars + chars.map(&:upcase) + %w[0 1 2 3 4 5 6 7 8 9]
      chars.shuffle!(random: Random.new(42))
      
      chars.each_with_index do |c, ind|
        st = [chars[ind-1], chars[ind-2], chars[ind-3], chars[ind-4], chars[ind-5]]
        (st.length+1).times do |i|
          strain = st.dup.insert(i, c).join('')
          text = "Strain #{strain} is most commonly found from example texts."
          expect(@tx.strains(text.dup, [strain], skipped_chars: [c], force_diff: true).split(' ')[1].split('')[i]).to eq(c)
          expect(@tx.strains(text.dup, [strain], skipped_chars: [c], force_diff: false).split(' ')[1].split('')[i]).to eq(c)
          
          skipped = [c, chars[ind-1], chars[ind-4]]
          res = @tx.strains(text.dup, [strain], skipped_chars: [c, chars[ind-1], chars[ind-4]], force_diff: true).split(' ')[1].split('')
          if i < 1
            expect(res[i]).to eq(skipped[0])
            expect(res[1]).to eq(skipped[1])
            expect(res[4]).to eq(skipped[2])
          elsif i < 4
            expect(res[i]).to eq(skipped[0])
            expect(res[0]).to eq(skipped[1])
            expect(res[4]).to eq(skipped[2])
          else
            expect(res[i]).to eq(skipped[0])
            expect(res[0]).to eq(skipped[1])
            expect(res[3]).to eq(skipped[2])
          end
        end
      end
    end
    
    it 'Scrambles strain names given as an array' do
      
      text = "E. coli strains K12 and Nissle 1917 are useful laboratory strains while O157:H7 and O26 are pathogenic. Therefore, it is advisable to stick with the usage of K12 and Nissle 1917 strains in basic laboratory experiments."
      
      strains = {}
      
      ['Nissle 1917', 'K12', 'O157:H7', 'O26'].each do |strain|
        strains[strain] = []
      end
      
      temp = ['']
      text.split(' ').each_with_index do |w, i|
        strains.each do |strain, arr|
          if (temp.last(strain.split(' ').length-1) + [w]).join(' ') == strain
            arr.push i - strain.split(' ').length + 1
          end
        end
        temp.push w
      end
      
      text = @tx.strains(text, strains.keys, force_diff: true)
      
      strains.each do |strain, locs|
        if locs.length > 0
          locs.each do |loc|
            expect(text.split(' ')[loc..loc+strain.split(' ').length-1].join(' ') == strain).to eq(false)
          end
        end
      end
    end
    
  end
  
  context 'general' do
    
    it 'Uses keyword arguments in obfuscation method' do
     
     test_strain = %w[a b c d e F g H i j k L m n o p q R s t Ρ Σ Τ Υ 4 5 θ ι κ λ μ].join('')
     test_string = "Escherichia coli #{test_strain} is a well-known laboratory strain."
     
     tx = Taxonomer.new(specseed: 42)
     res = tx.obfuscate(test_string.dup, [test_strain], rseed: 42)
     tx = Taxonomer.new(specseed: 42)
     res2 = tx.obfuscate(test_string.dup, [test_strain], rseed: 42)
     tx = Taxonomer.new(specseed: 42)
     res3 = tx.obfuscate(test_string.dup, [test_strain], rseed: 43)
     expect(res == res2).to eq(true)
     expect(res == res3).to eq(false)
     
     res = @tx.obfuscate(test_string.dup, [test_strain], rseed: 42)
     res2 = tx.obfuscate(test_string.dup, [test_strain], rseed: 42)
     expect(res.split[2] == res2.split[2]).to eq(true)
     
     res2 = tx.obfuscate(test_string.dup, [test_strain], rseed: 43)
     expect(res.split[2] == res2.split[2]).to eq(false)
     
     tx = Taxonomer.new(specseed: 42)
     res = tx.obfuscate(test_string.dup, [test_strain], force_diff: true)
     res.split[2].split('').each_with_index do |c, i|
       expect(c == test_strain[i]).to eq(false)
     end
     
     found = false
     10000.times do
       res = @tx.obfuscate(test_string.dup, [test_strain])
       res.split[2].split('').each_with_index do |c, i|
         found = test_strain[i] == c unless found
       end
       break if found
     end
     expect(found).to eq(true)
     
     
     test_strain = %w[a b c d δ F g H i j Δ k L m n o p q R s t Ρ Σ Τ Υ 4 5 θ ι κ λ μ].join('')
     test_string = "Escherichia coli #{test_strain} is a well-known laboratory strain."
     
     res = @tx.obfuscate(test_string.dup, [test_strain])
     ['δ', 'Δ'].each do |c|
       expect(res.split[2].split('')[test_strain.index(c)] == c).to eq(true)
     end
     
     conserved = %w[d L R s Σ Τ 5 κ λ]
     res = @tx.obfuscate(test_string.dup, [test_strain], skipped_chars: conserved)
     conserved.each do |c|
       expect(res.split[2].split('')[test_strain.index(c)] == c).to eq(true)
     end
     
    end
    
    it 'Can shuffle the species list by using a random seed' do
      l1 = Taxonomer.new(specseed: 42).species_list.last(10)
      l2 = Taxonomer.new(specseed: 42).species_list.last(10)
      l3 = Taxonomer.new(specseed: 43).species_list.last(10)
      
      expect(l1 == l2).to eq(true)
      expect(l1 == l3).to eq(false)
    end
    
    it 'Uses different random seeds to shuffle the species list if the seed is not specified' do
      l1 = Taxonomer.new.species_list.last(10)
      l2 = Taxonomer.new.species_list.last(10)
      expect(l1 == l2).to eq(false)
    end
    
    it 'Ensures that the input and output texts have same number of words when scrambling is not forced' do
      text = "Escherichia coli K12 is a well-known laboratory strain. However, the same laboratories can study more uncommon E. coli strains, such as the K12-566 or strains from completely different species, such as P. syringae pv. tomato, which is a plant pathogen."
      word_len = text.split.length
      text = @tx.obfuscate(text, ['K12', 'K12-566', 'pv. tomato'])
      expect(word_len).to eq(text.split.length)
    end
    
    it 'Ensures that the input and output texts have same number of words when scrambling is forced' do
      text = "Escherichia coli K12 is a well-known laboratory strain. However, the same laboratories can study more uncommon E. coli strains, such as the K12-566 or strains from completely different species, such as P. syringae pv. tomato, which is a plant pathogen."
      text = @tx.obfuscate(text, ['K12', 'K12-566', 'pv. tomato'], force_diff: true)
      word_len = text.split.length
      expect(word_len).to eq(text.split.length)
    end
    
  end
  
  context 'species' do 
    it 'Switches species names in given strings' do
      text = "E. coli is a bacterial species that is also known as Escherichia coli."
      expected = @tx.species_list.last
      text = @tx.species(text)
      text = text.split
      expect(text[0..1].join(' ')).to eq("#{expected[0]}. #{expected.split()[1]}")
      expect("#{text[text.length-2]} #{text.last}".gsub('.','')).to eq(expected)
    end
    
    it 'Switches multiple species names into new' do
      text = "Plant pathogen Pseudomonas syringae is a significant challenge to the commercial agriculture while E. coli can be easily controlled by post-harvest hygiene. However, P. syringae and E. coli are only two examples of bacterium that cause foodborne and plant diseases, and other pathogenic bacteria such as Dickeya dadantii are also considered important burdens to the agricultural production around the world."
      
      expected = @tx.species_list.last(3)
      tracked = {}
      ['Pseudomonas syringae', 'Dickeya dadantii', 'Escherichia coli'].each do |species|
        exp = expected.pop
        tracked[species] = {:locs => [], :expected => exp}
        tracked["#{species[0]}. #{species.split(' ')[1]}"] = {:locs => [], :expected => "#{exp[0]}. #{exp.split(' ')[1]}"}
      end
      
      temp = ""
      text.split(' ').each_with_index do |w, i|
        tracked.keys.each do |s|
          tracked[s][:locs].push i-1 if "#{temp} #{w}" == s
        end
        temp = w
      end
    
      text = @tx.species(text).split
      tracked.values.each do |d|
        d[:locs].each do |loc|
          expect(text[loc..loc+1].join(' ')).to eq(d[:expected])
        end
      end
    end
    
    
    # uses a fresh instance
    it 'Does not run out of species names and regenerates the species name list to correct length' do
      tx = Taxonomer.new
      spec_list = tx.species_list
      num_species = spec_list.length
      
      expect(num_species).to be > 0
      
      (num_species-1).times do
        tx.sample
      end
      expect(tx.species_list.length).to eq(1)
      
      tx.sample
      expect(tx.species_list.length).to eq(0)
      
      spec_list.delete(tx.sample)
      expect(tx.species_list.length).to eq(num_species-1)
      spec_list.length.times do
        spec_list.delete(tx.sample)
      end
      
      expect(spec_list.length).to be(0)
    end
  end
  
end
