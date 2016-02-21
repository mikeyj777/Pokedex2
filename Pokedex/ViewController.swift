//
//  ViewController.swift
//  Pokedex
//
//  Created by macuser on 2/20/16.
//  Copyright © 2016 ResponseApps. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet var searchBar: UISearchBar!
    var pokemon = [Pokemon]()
    
    var mPlayer:AVAudioPlayer!
    
    var playMusic = false
    
    var inSearchMode = false
    
    var filteredPokemon = [Pokemon]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done
        initAudio()
        parsePokemonCSV()
        
    }

    func initAudio() {
        
        if playMusic {
            let path = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")!
            
            do {
                
                    mPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string:path)!)
                    mPlayer.prepareToPlay()
                    mPlayer.numberOfLoops = -1
                    mPlayer.play()
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        
    }
    
    @IBAction func musicToggleBtn(sender: UIButton!) {
        if playMusic {
            if mPlayer.playing {
                mPlayer.stop()
                sender.alpha = 0.2
            } else {
                mPlayer.play()
                sender.alpha = 1.0
            }
        }
    }
    
    func parsePokemonCSV() {
        
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                let poke = Pokemon(name:name, pokedexId:pokeId)
                pokemon.append(poke)
            }
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
            
            if inSearchMode {
                cell.configureCell(filteredPokemon[indexPath.row])
            } else {
                cell.configureCell(pokemon[indexPath.row])
            }
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let poke: Pokemon!
        
        if inSearchMode {
            poke = filteredPokemon[indexPath.row]
        } else {
            poke = pokemon[indexPath.row]
        }
        
        performSegueWithIdentifier("PokemonDetailVC", sender: poke)
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredPokemon.count
        }
        
        return pokemon.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(105,105)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" || searchBar.text == nil {
            inSearchMode = false
            view.endEditing(true)
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercaseString
            
            //$0 grabs first element, giving number zero.
            //rangeOfString treats the characters entered as a range.  the array is then filtered by that range of values.
            filteredPokemon = pokemon.filter({
                $0.name.rangeOfString(lower) != nil
            })
        }
        collection.reloadData()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //close keyboard
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destinationViewController as? PokemonDetailVC {
                if let poke = sender as? Pokemon {
                    detailsVC.pokemon = poke
                }
            }
        }
        
        
    }
    
}

