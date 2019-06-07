module.exports = (res, err) => {
	console.log(`Error: ${err.type}`)
	res.status(err.code).json(err)
}
