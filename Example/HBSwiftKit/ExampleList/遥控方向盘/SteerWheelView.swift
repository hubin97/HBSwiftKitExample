//
//  SteerWheelView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/3/31.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods
protocol SteerWheelAdapter: AnyObject {
    func adapter(tapPanel: SteerWheelView, position: SteerWheelView.PanelPosition)
    func adapter(longPressPanel: SteerWheelView, position: SteerWheelView.PanelPosition, state: UIGestureRecognizer.State)
}

extension SteerWheelAdapter {
    func adapter(longPressPanel: SteerWheelView, position: SteerWheelView.PanelPosition, state: UIGestureRecognizer.State) {}
}

// MARK: - main class
class SteerWheelView: UIView {
    enum PanelPosition {
        case top
        case bottom
        case left
        case right
        case center

        func drawPoints(with view: SteerWheelView) -> [CGPoint] {
            let radiusl = view.height/2
            let radiuss = view.height/4
            let rAngle = sin(Double.pi / 4)
            switch self {
            case .top:
                return [CGPoint(x: (1 - rAngle) * radiuss, y: (1 - rAngle) * radiuss),
                        CGPoint(x: (1 - rAngle) * radiusl, y: (1 - rAngle) * radiusl),
                        CGPoint(x: view.width/2 + rAngle * radiusl, y: (1 - rAngle) * radiusl)]
            case .left:
                return [CGPoint(x: (1 - rAngle) * radiuss, y: (1 - rAngle) * radiuss),
                        CGPoint(x: (1 - rAngle) * radiusl, y: (1 - rAngle) * radiusl),
                        CGPoint(x: (1 - rAngle) * radiusl, y: view.height/2 + rAngle * radiusl)]
            case .bottom:
                return [CGPoint(x: (1 - rAngle) * radiuss, y: view.height - (1 - rAngle) * radiuss),
                        CGPoint(x: (1 - rAngle) * radiusl, y: view.height/2 + rAngle * radiusl),
                        CGPoint(x: (1 + rAngle) * radiusl, y: view.height/2 + rAngle * radiusl)]
            case .right:
                return [CGPoint(x: view.width - (1 - rAngle) * radiuss, y: (1 - rAngle) * radiuss),
                        CGPoint(x: view.width/2 + rAngle * radiusl, y: (1 - rAngle) * radiusl),
                        CGPoint(x: (1 + rAngle) * radiusl, y: view.height/2 + rAngle * radiusl)]
            default:
                return []
            }
        }
    }

    weak var panelAdapter: SteerWheelAdapter?
    var adaptPosition: PanelPosition?
    //var tColor: UIColor?

    //
    let sw_panel_normal = UIImage(named: "sw_panel_normal")
    let sw_panel_top    = UIImage(named: "sw_panel_top")
    let sw_panel_bottom = UIImage(named: "sw_panel_bottom")
    let sw_panel_left   = UIImage(named: "sw_panel_left")
    let sw_panel_right  = UIImage(named: "sw_panel_right")
    let sw_panel_ok     = UIImage(named: "sw_panel_ok")

    lazy var bgImgView: UIImageView = {
        let _drawLayer = UIImageView.init(image: sw_panel_normal)
        _drawLayer.frame = self.bounds
        _drawLayer.isUserInteractionEnabled = true
        return _drawLayer
    }()
    lazy var drawLayer_top: CAShapeLayer = {
        let _drawLayer = CAShapeLayer()
        _drawLayer.fillColor = UIColor.white.cgColor
        return _drawLayer
    }()
    lazy var drawLayer_left: CAShapeLayer = {
        let _drawLayer = CAShapeLayer()
        _drawLayer.fillColor = UIColor.white.cgColor
        return _drawLayer
    }()
    lazy var drawLayer_bottom: CAShapeLayer = {
        let _drawLayer = CAShapeLayer()
        _drawLayer.fillColor = UIColor.white.cgColor
        return _drawLayer
    }()
    lazy var drawLayer_right: CAShapeLayer = {
        let _drawLayer = CAShapeLayer()
        _drawLayer.fillColor = UIColor.white.cgColor
        return _drawLayer
    }()
    lazy var drawLayer_center: CAShapeLayer = {
        let _drawLayer = CAShapeLayer()
        _drawLayer.fillColor = UIColor.white.cgColor
        return _drawLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGes(_:))))
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressGes(_:))))
        self.setUp()
        self.addSubview(bgImgView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.isHidden == false && self.isUserInteractionEnabled == true && self.alpha > 0.01 else { return nil }
        guard self.point(inside: point, with: event) else { return nil }
        if let hitView = self.subviews.reversed().first(where: { $0.hitTest(convert(point, to: $0), with: event) != nil }) {
            return hitView
        }
        return self
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let radius = self.height/2
        let centerx = self.width/2
        let centery = self.height/2
        let distance = sqrt((centerx - point.x) * (centerx - point.x) + (centery - point.y) * (centery - point.y))
        return distance < radius
    }

    //swiftlint:disable function_body_length
    func setUp() {
        let radiusl = self.height/2
        let radiuss = self.height/4
        let drawOrder: [PanelPosition] = [.top, .left, .bottom, .right, .center]
        drawOrder.forEach { ppositon in
            switch ppositon {
            case .top:
                let path = UIBezierPath()
                path.move(to: ppositon.drawPoints(with: self)[0])
                path.addLine(to: ppositon.drawPoints(with: self)[1])
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiusl, startAngle: -(.pi * 3/4), endAngle: -(.pi/4), clockwise: true)
                path.addLine(to: ppositon.drawPoints(with: self)[2]) /// ???
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiuss, startAngle: -(.pi/4), endAngle: -(.pi * 3/4), clockwise: false)
                path.close()
                drawLayer_top.path = path.cgPath
                layer.addSublayer(drawLayer_top)
            case .left:
                let path = UIBezierPath()
                path.move(to: ppositon.drawPoints(with: self)[0])
                path.addLine(to: ppositon.drawPoints(with: self)[1])
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiusl, startAngle: -(.pi * 3/4), endAngle: .pi * 3/4, clockwise: false)
                path.addLine(to: ppositon.drawPoints(with: self)[2])
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiuss, startAngle: .pi * 3/4, endAngle: -(.pi * 3/4), clockwise: true)
                path.close()
                drawLayer_left.path = path.cgPath
                layer.addSublayer(drawLayer_left)
            case .bottom:
                let path = UIBezierPath()
                path.move(to: ppositon.drawPoints(with: self)[0])
                path.addLine(to: ppositon.drawPoints(with: self)[1])
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiusl, startAngle: .pi * 3/4, endAngle: .pi/4, clockwise: false)
                path.addLine(to: ppositon.drawPoints(with: self)[2])
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiuss, startAngle: .pi/4, endAngle: .pi * 3/4, clockwise: true)
                path.close()
                drawLayer_bottom.path = path.cgPath
                layer.addSublayer(drawLayer_bottom)
            case .right:
                let path = UIBezierPath()
                path.move(to: ppositon.drawPoints(with: self)[0])
                path.addLine(to: ppositon.drawPoints(with: self)[1])
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiusl, startAngle: -.pi/4, endAngle: .pi/4, clockwise: true)
                path.addLine(to: ppositon.drawPoints(with: self)[2]) /// ???
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiuss, startAngle: .pi/4, endAngle: -.pi/4, clockwise: false)
                path.close()
                drawLayer_right.path = path.cgPath
                layer.addSublayer(drawLayer_right)
            case .center:
                let path = UIBezierPath()
                path.addArc(withCenter: CGPoint(x: self.width/2, y: self.height/2), radius: radiuss, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                path.close()
                drawLayer_center.path = path.cgPath
                layer.addSublayer(drawLayer_center)
            }
        }
        setNeedsDisplay()
    }
}

// MARK: private methods
extension SteerWheelView {

    func fillBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
        drawLayer_center.fillColor = color.cgColor
        drawLayer_top.fillColor = color.cgColor
        drawLayer_left.fillColor = color.cgColor
        drawLayer_bottom.fillColor = color.cgColor
        drawLayer_right.fillColor = color.cgColor
    }

    // 暂不使用
    func fetchLayer(position: PanelPosition) -> CAShapeLayer {
        switch position {
        case .center:
            return self.drawLayer_center
        case .top:
            return self.drawLayer_top
        case .left:
            return self.drawLayer_left
        case .bottom:
            return self.drawLayer_bottom
        case .right:
            return self.drawLayer_right
        }
    }

    func fetchImgState(position: PanelPosition?) -> UIImage {
        switch position {
        case .center:
            return self.sw_panel_ok!
        case .top:
            return self.sw_panel_top!
        case .left:
            return self.sw_panel_left!
        case .bottom:
            return self.sw_panel_bottom!
        case .right:
            return self.sw_panel_right!
        case .none:
            return self.sw_panel_normal!
        }
    }

    // 余弦定理 CosC=(a^2+b^2-c^2)/2ab
    func eventHandle(_ ges: String, _ point: CGPoint) {
        self.adaptPosition = nil
        // x轴边
        let origin = CGPoint(x: self.width, y: self.height/2)
        // 圆点
        let anchor = CGPoint(x: self.width/2, y: self.height/2)
        let disa = self.width/2
        let disb = sqrt((anchor.x - point.x) * (anchor.x - point.x) + (anchor.y - point.y) * (anchor.y - point.y))
        let disc = sqrt((origin.x - point.x) * (origin.x - point.x) + (origin.y - point.y) * (origin.y - point.y))
        let cosc = (disa * disa + disb * disb - disc * disc) / (2 * disa * disb)
        let angle = point.y < anchor.y ? acos(cosc) * 180 / .pi: (360 - acos(cosc) * 180 / .pi)
        // 限制在环内?
        guard disb > disa/2 && disb < disa else {
            print("\(ges) - Center")
            adaptPosition = .center
            return
        }
        switch angle {
        case 45...135:
            print("\(ges) - Top")
            adaptPosition = .top
        case 135...225:
            print("\(ges) - Left")
            adaptPosition = .left
        case 225...315:
            print("\(ges) - Bottom")
            adaptPosition = .bottom
        case 0...45, 315...360:
            print("\(ges) - Right")
            adaptPosition = .right
        default:
            break
        }
    }
}

// MARK: call backs
extension SteerWheelView {

    @objc func tapGes(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: self)
        self.eventHandle("UITapGes", point)
        guard let p = adaptPosition else { return }
        print("tap.state:\(tap.state.rawValue)")

        //TapImpact.heavy()
        self.bgImgView.image = fetchImgState(position: p)
        if tap.state == .ended {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.bgImgView.image = self.fetchImgState(position: nil)
            }
        }
        panelAdapter?.adapter(tapPanel: self, position: p)
    }

    @objc func longPressGes(_ longPres: UILongPressGestureRecognizer) {
        let point = longPres.location(in: self)
        switch longPres.state {
        case .began:
            print("began")
            self.eventHandle("UILongPressGes", point)
            guard let p = adaptPosition else { return }
            //TapImpact.heavy()
            self.bgImgView.image = fetchImgState(position: p)
            panelAdapter?.adapter(longPressPanel: self, position: p, state: .began)
        case .ended, .cancelled:
            print("ended, .cancelled")
            guard let p = adaptPosition else { return }
            self.bgImgView.image = fetchImgState(position: nil)
            panelAdapter?.adapter(longPressPanel: self, position: p, state: longPres.state)
        default:
            break
        }
    }
}
