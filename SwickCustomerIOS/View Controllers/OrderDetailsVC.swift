//
//  OrderDetailsVC.swift
//  SwickCustomerIOS
//
//  Created by Sean Lu on 5/13/20.
//  Copyright © 2020 Swick. All rights reserved.
//

import UIKit

class OrderDetailsVC: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView()
    
    // Order clicked on in previous view
    var order: Order!
    // Order details from API call
    var orderDetails = OrderDetails()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set navigation bar title to restaurant name
        self.title = order.restaurantName
        loadOrderDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadOrderDetails()
    }
    
    // Reload when refresh button is clicked
    @IBAction func refresh(_ sender: Any) {
        loadOrderDetails()
    }
    
    func loadOrderDetails() {
        // Show activity indicator while loading data
        Helper.showActivityIndicator(self.activityIndicator, view)
        
        // Load time into view with object from previous view
        timeLabel.text = order.time
        
        // Load order details from API call
        APIManager.shared.getOrderDetails(orderId: order.id!) { json in
            self.orderDetails = OrderDetails(json: json["order_details"])
            
            self.statusLabel.text = self.orderDetails.status
            self.tableLabel.text = self.orderDetails.table
            self.serverLabel.text = self.orderDetails.serverName
            self.totalLabel.text = Helper.formatPrice(self.orderDetails.total)
            
            // Reload table view after getting menu data from server
            self.tableView.reloadData()
            // Hide activity indicator when finished loading data
            Helper.hideActivityIndicator(self.activityIndicator)
        }
    }
}

extension OrderDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    // Set number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails.items.count
    }
    
    // Properties for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailsCell", for: indexPath) as! OrderDetailsCell
        let orderItem = orderDetails.items[indexPath.row]
        
        // Set labels
        cell.mealNameLabel.text = orderItem.mealName
        cell.quantityLabel.text = orderItem.quantity
        cell.totalLabel.text = Helper.formatPrice(orderItem.total)
        
        // Build customization label and set
        var custText = ""
        for cust in orderItem.customizations {
            custText += cust.name + "\n"
            for opt in cust.options {
                custText += "- " + opt + "\n"
            }
        }
        // Remove last new line
        if custText != "" {
            custText.remove(at: custText.index(before: custText.endIndex))
        }
        cell.customizationLabel.text = custText
        
        return cell
    }
}
