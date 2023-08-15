//
//  ViewController.swift
//  Assignment4
//
//  Created by user225115 on 8/11/23.
//

import UIKit
import Foundation

extension Date {
    static func dateFromNageruFormat(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: string)
    }
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    
    func fetchEvents() {
        guard let url = URL(string: "https://date.nager.at/api/v3/PublicHolidays/2023/CA") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        var updatedEventsList = [Event]()
                        
                        for holiday in jsonArray {
                            if let name = holiday["localName"] as? String,
                               let dateString = holiday["date"] as? String,
                               let date = Date.dateFromNageruFormat(string: dateString) {
                                
                                let event = Event() // Instantiate an Event object
                                event.id = 0 // Assign an appropriate ID
                                event.name = name
                                event.date = date
                                
                                updatedEventsList.append(event)
                            }
                        }
                        
                        // Update eventsList on the main thread
                        DispatchQueue.main.async {
                            eventsList = updatedEventsList
                            self.collectionView.reloadData()
                        }
                    } else {
                        print("Invalid JSON format")
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }
        }
        task.resume()
    }



    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    
    var totalSquares = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchEvents()
        setCellsView()
        setMonthView()
    }

    
    func setCellsView()
    {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonthView()
    {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while(count <= 42)
        {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth)
            {
                totalSquares.append("")
            }
            else
            {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        
        monthLabel.text = CalendarHelper().monthString(date: selectedDate)
            + " " + CalendarHelper().yearString(date: selectedDate)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        
        cell.dayOfMonth.text = totalSquares[indexPath.item]
        
        return cell
    }
    
    @IBAction func previousMonth(_ sender: Any)
    {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonth(_ sender: Any)
    {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
}
