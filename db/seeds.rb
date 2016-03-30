Balance.find_or_create_by(name: '2016', amount: 1342, current: true)

Goal.find_or_create_by(name: "Beers", amount: 250, achieved_on: "2016-01-18")
Goal.find_or_create_by(name: "Tennis", amount: 1000, achieved_on: "2016-02-24")
Goal.find_or_create_by(name: "Karten", amount: 1500, achieved_on: nil)
Goal.find_or_create_by(name: "Barbeque", amount: 2500, achieved_on: nil)

# :amount kudos to :user for :name
Activity.find_or_create_by(name: "writing a blog post", amount: 40)
Activity.find_or_create_by(name: "presenting at a conference", amount: 150)
Activity.find_or_create_by(name: "reaching the monthly revenue goal of 200k", amount: 500)
Activity.find_or_create_by(name: "helping me out", amount: 1)
