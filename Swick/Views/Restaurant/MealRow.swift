//
//  MealRow.swift
//  Swick
//
//  Created by Sean Lu on 10/7/20.
//

import SwiftUI

struct MealRow: View {
    // Properties
    var meal: Meal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10.0) {
                Text(meal.name)
                    .font(SFont.header)
                if let description = meal.description {
                    Text(description)
                        .font(SFont.body)
                        .lineLimit(1)
                }
                Text(Helper.formatPrice(meal.price))
                    .font(SFont.body)
            }
            Spacer()
            if let imageUrl = meal.imageUrl {
                ThumbnailImage(url: imageUrl)
            }
        }
        .padding(.vertical)
    }
}

struct MealRow_Previews: PreviewProvider {
    static var previews: some View {
        MealRow(meal: testMeal1)
    }
}
