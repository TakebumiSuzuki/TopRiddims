//
//  LikesTableViewCell.swift
//  TopRiddims
//
//  Created by TAKEBUMI SUZUKI on 3/30/21.
//

import UIKit
import Firebase
import SDWebImage

protocol LikesTableViewCellDelegate: class{
    func heartButtonTapped(cell: LikesTableViewCell, buttonState: Bool)
    func checkButtonTapped(cell: LikesTableViewCell, buttonState: Bool)
    
}

class LikesTableViewCell: UITableViewCell {

    static let identifier = "LikesTableCell"
    weak var delegate: LikesTableViewCellDelegate?
    
    private var heartButtonOnOff: Bool = false{
        didSet{
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin, scale: .medium)
            if heartButtonOnOff{
                let image = UIImage(systemName: "suit.heart.fill", withConfiguration: config)
                heartButton.setImage(image, for: .normal)
                heartButton.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            }else{
                let image = UIImage(systemName: "suit.heart", withConfiguration: config)
                heartButton.setImage(image, for: .normal)
                heartButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }
    }
    
    private var checkButtonOnOff: Bool = false{
        didSet{
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .thin, scale: .medium)
            if checkButtonOnOff{
                let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
                checkButton.setImage(image, for: .normal)
                checkButton.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            }else{
                let image = UIImage(systemName: "checkmark.circle", withConfiguration: config)
                checkButton.setImage(image, for: .normal)
                checkButton.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }
    }
    
    var song: Song!{
        didSet{
            configureCell()
            
        }
    }
    
    let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 2
        iv.clipsToBounds = true
        iv.backgroundColor = .separator
        return iv
    }()
    
    let songNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .light)
        return lb
    }()
    let artistNameLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    private lazy var heartButton: UIButton = {
        let bn = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin, scale: .medium)
//        let image = UIImage(systemName: "suit.heart", withConfiguration: config)
//        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.addTarget(self, action: #selector(heartButtonPressed), for: .touchUpInside)
        return bn
    }()
    private lazy var checkButton: UIButton = {
        let bn = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin, scale: .medium)
//        let image = UIImage(systemName: "checkmark.circle", withConfiguration: config)
//        bn.setImage(image, for: .normal)
        bn.contentMode = .scaleAspectFit
        bn.addTarget(self, action: #selector(checkButtonPressed), for: .touchUpInside)
        return bn
    }()
    
    private let dateLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return lb
    }()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("ここが呼ばれない！ ")
   }
    
    func configureCell(){
        songNameLabel.text = song.songName
        artistNameLabel.text = song.artistName
        dateLabel.text =  CustomDateFormatter.formatter.string(from: song.likedStateUpdateDate.dateValue())
        heartButtonOnOff = song.liked
        checkButtonOnOff = song.checked
        
        
        self.backgroundColor = .systemBackground
        
        self.contentView.addSubview(thumbnailImageView)
        thumbnailImageView.sd_setImage(with: URL(string: song.thumbnailURL), completed: nil)
        
        self.contentView.addSubview(songNameLabel)
        self.contentView.addSubview(artistNameLabel)
        
        self.contentView.addSubview(heartButton)
        self.contentView.addSubview(checkButton)
        self.contentView.addSubview(dateLabel)
        
        thumbnailImageView.anchor(top: self.topAnchor, left: self.leftAnchor, paddingTop: 8, paddingLeft: 10, width: 44/9*16, height: 44)
        
        songNameLabel.anchor(top: self.topAnchor, left: thumbnailImageView.rightAnchor, paddingTop: 10, paddingLeft: 10)
        songNameLabel.setContentCompressionResistancePriority(UILayoutPriority.init(100), for: .horizontal)
        artistNameLabel.anchor(top: songNameLabel.bottomAnchor, left: songNameLabel.leftAnchor, paddingTop: 3)
        artistNameLabel.setContentCompressionResistancePriority(UILayoutPriority.init(100), for: .horizontal)
        
        checkButton.anchor(right: self.rightAnchor, paddingRight: 16)
        checkButton.lastBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        
        heartButton.anchor(right: checkButton.leftAnchor, paddingRight: 10)
        heartButton.lastBaselineAnchor.constraint(equalTo: songNameLabel.firstBaselineAnchor).isActive = true
        
        dateLabel.anchor(right: self.rightAnchor, paddingRight: 16)
        dateLabel.lastBaselineAnchor.constraint(equalTo: artistNameLabel.firstBaselineAnchor).isActive = true
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    
    
    @objc private func heartButtonPressed(){
        heartButtonOnOff.toggle()
        delegate?.heartButtonTapped(cell: self, buttonState: heartButtonOnOff)
        
    }
    @objc private func checkButtonPressed(){
        checkButtonOnOff.toggle()
        delegate?.checkButtonTapped(cell: self, buttonState: heartButtonOnOff)
    }

}
