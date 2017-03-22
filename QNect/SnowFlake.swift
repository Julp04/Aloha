//
//  Emitter.swift
//  Emitting
//
//  Created by Panucci, Julian R on 3/17/17.
//  Copyright © 2017 Panucci, Julian R. All rights reserved.
//

import Foundation
import UIKit


class Snowflake: CAEmitterLayer {
    
    //MARK: Constants
    static let kParticleCount = 5
    
    //MARK: Overrides
    
    override var emitterZPosition:CGFloat {
        get {
            return 10.0
        } set {
            self.emitterZPosition = newValue
        }
    }
    
    override var emitterShape: String {
        get {
            return kCAEmitterLayerLine
        }set {
            self.emitterShape = newValue
        }
    }
    
    //MARK: Cell Properties
    
    var emissionRange = CGFloat(M_PI)
    var particleSize:CGFloat = 0.3 {
        didSet {
            emitterCells?.forEach {$0.scale = particleSize}
        }
    }
    var particleSizeRange:CGFloat = 0.5 {
        didSet {
            emitterCells?.forEach { $0.scaleRange = particleSizeRange }
        }
    }
    
    //MARK: Other Properties
    
    private var totalParticles: Int
    var particleCount: Int {
        didSet {
            emitterCells?.forEach {$0.birthRate = Float(particleCount / totalParticles)}
        }
    
    }
    
    required init(view: UIView, particles: [UIImage: UIColor]) {

        totalParticles = particles.keys.count
        particleCount = Snowflake.kParticleCount
        super.init()
        
        emitterSize = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
        position = CGPoint(x: view.bounds.width / 2, y: view.bounds.origin.y - 50)

        var emitterCells = [CAEmitterCell]()
        for (image) in particles.keys {
            
            let color =  particles[image]!
            let particle = self.createParticle(image: image, color: color)
            
            emitterCells.append(particle)
        }
        
        self.emitterCells = emitterCells
        self.isHidden = true
    }
    
    
    /// Choose a single color for all particles snowing
    ///
    /// - Parameters:
    ///   - view: where it will snow ❄️️
    ///   - particles: images of each particle
    ///   - color: single color for all particles
    convenience init(view: UIView, particles: [UIImage], color: UIColor) {
        
        var dict = [UIImage: UIColor]()
        
        for image in particles {
            dict[image] = color
        }
        
        self.init(view: view, particles: dict)
    }
    
    convenience init(view: UIView, particleImages: [UIImage]) {
        self.init(view: view, particles: particleImages, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5))
    }
    
    
    private func createParticle(image: UIImage, color: UIColor) -> CAEmitterCell {
        
        let emitterCell = CAEmitterCell()// 6
        emitterCell.scale = particleSize // 7
        emitterCell.scaleRange = particleSizeRange; // 8
        emitterCell.emissionRange = emissionRange
        emitterCell.emissionLongitude = 30
        emitterCell.color = color.cgColor
        
        emitterCell.lifetime = 50; // 10
        emitterCell.birthRate = Float(particleCount / totalParticles)
        
        emitterCell.velocity = 10; // 12
        emitterCell.velocityRange = 50; // 13
        emitterCell.yAcceleration = 5; // 14
        emitterCell.xAcceleration = 1;
        emitterCell.spin = 0.01
        
        
        emitterCell.contents = image.cgImage
        
        return emitterCell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Public Functions
    
    public func stop()
    {
        self.isHidden = true
    }
    
    public func start() {
        self.isHidden = false
    }
    
    
}

