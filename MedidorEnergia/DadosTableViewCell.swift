//
//  DadosTableViewCell.swift
//  MedidorEnergia
//
//  Created by Matheus Santos on 23/09/18.
//  Copyright © 2018 Matheus Santos. All rights reserved.
//

import UIKit

class DadosTableViewCell: UITableViewCell {

    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var correnteLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
