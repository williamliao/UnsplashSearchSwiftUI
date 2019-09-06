/*
Copyright (c) 2017 http://www.swiftjson.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

struct Response: Codable, Identifiable {
	let id: String
	let created_at: String
	let updated_at: String
	let width: Int
	let height: Int
	let color: String
	let description: String?
	let alt_description: String?
	let urls: Urls
	let links: Links
	let categories: Categories?
	let likes: Int?
	let liked_by_user: Bool
	let current_user_collections: Current_user_collections?
	let user: User?
	let exif: Exif?
	let location: Location?
	let views: Int
	let downloads: Int
}
