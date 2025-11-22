# Campus Canteen Online Ordering System - WeChat Mini Program

This is the WeChat Mini Program frontend for the Campus Canteen Online Ordering System.

## Important: TabBar Icons

**Note**: The WeChat Mini Program `tabBar` configuration strictly requires **PNG** or **JPG** files. It does not support SVG files for the tab icons.

Due to a technical limitation in the automatic environment (path encoding with Chinese characters), the icon files could not be copied automatically.

**Action Required**:
Please manually copy the following images from your backend resources to the frontend assets folder:

**Source Directory**: `backend/src/main/resources/front/images/`
**Destination Directory**: `frontend/user/assets/icons/`

Please copy and rename as follows:

1.  `home.png` -> `home.png` AND `home-active.png`
2.  `orders.png` -> `order.png` AND `order-active.png`
3.  `user.png` -> `user.png` AND `user-active.png`

The `app.json` has been configured to look for these PNG files.

## Project Structure

```
frontend/user/
  ├── app.js             # Global logic
  ├── app.json           # Global configuration
  ├── app.wxss           # Global styles
  ├── project.config.json # DevTools configuration
  ├── pages/             # Page directories
  ├── utils/
  └── assets/
      └── icons/         # Place PNG icons here
```

## Setup Instructions

1.  **Install WeChat Developer Tools**.
2.  **Import Project**: Select `frontend/user`.
3.  **Backend Connection**: Ensure backend is running at `http://localhost:8080`.
