//
//  README.md
//  SwiftUILayoutInMac
//
//  Created by Karthik K Manoj on 17/05/24.
//

import Foundation

- Fixed frame ( only height and width and alignment. We cannot say origin is at 1, 1)
- centers the content if no alignment is specified
- If the content is bigger than fixed frame, fixed size frame is reported and content is centered
- need extension on view to call `frame` and some type to represent fixed frame.


1) If it's a built in view then we either do the rendering of it's kind. So for a frame we do layout calculation
2) If it's a shape then we do drawing of the shape
3) If it's a user defiend view then we call the body which is another view 
4) We need to map Shape_ to Shape. We can either compute shapView by adding it as a requirement inside 
`Shape_` or we can type erase it by wrapping `Shape` inside `AnyShape`
