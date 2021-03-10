//
//  RealmFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Romain Brunie on 09/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmFeedImage: Object {
	@objc dynamic var id: String = ""
	@objc dynamic var desc: String? = nil
	@objc dynamic var location: String? = nil
	@objc dynamic var url: String = ""
	
	public convenience init(id: UUID, description: String?, location: String?, url: URL) {
		self.init()
		self.id = id.uuidString
		self.desc = description
		self.location = location
		self.url = url.absoluteString
	}
	
	public func toLocal() throws -> LocalFeedImage {
		guard let uuid = UUID(uuidString: self.id), let url = URL(string: self.url) else {
			throw InvalidFeedImageData()
		}
		
		return LocalFeedImage(id: uuid,
							  description: self.desc,
							  location: self.location,
							  url: url)
	}
	
	struct InvalidFeedImageData: Error {}
}
