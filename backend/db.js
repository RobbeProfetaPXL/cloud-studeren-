const mongoose = require('mongoose');
(async () => {
    try {
      const db = await mongoose.connect(process.env.DBURL || 'database-1.cxei26wwqrnv.us-east-1.rds.amazonaws.com');
      console.log("Db connectect to", db.connection.name);
    } catch (error) {
      console.error(error);
    }
  })();