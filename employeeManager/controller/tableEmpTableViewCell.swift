//
//  tableEmpTableViewCell.swift
//  coreDataExample
//
//  Created by E5000846 on 17/06/24.
//

import UIKit

class tableEmpTableViewCell: UITableViewCell {

    static let identifier = "tableEmpTableViewCell"
    
    @IBOutlet weak var profImg: UIImageView!
    
    @IBOutlet weak var nameLb: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
