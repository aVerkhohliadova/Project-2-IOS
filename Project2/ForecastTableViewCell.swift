//
//  ForecastTableViewCell.swift
//  Project2
//
//  Created by Алла Верхоглядова on 04.04.2023.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

    let dayLabel = UILabel()
    let temperatureLabel = UILabel()
    let iconImage = UIImage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dayLabel.frame = CGRect(x: 10, y: 10, width: 80, height: 30)
        temperatureLabel.frame = CGRect(x: 100, y: 10, width: 80, height: 30)
        
        // Other layout customizations for the cell...
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(temperatureLabel)
//        contentView.addSubview(iconImage)
        
        // Other customizations for the cell...
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
