# import flask
# pip install flask
# from flask import Flask, render_template, request
from flask import Flask, render_template, request
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
app = Flask(__name__)
# book_title = ''
# Load data
df = pd.read_excel('D:/DAIHOC/KY6/QTCSDL/KEYWORD.xlsx')

# Pivot table
user_book_df = df.pivot_table(index=['ID'],columns=['Tên sách'], values='Điểm đánh giá').astype('float16')

def custom_recommender(book_title):
    
    #ITEM-BASED
    book_title = str(book_title)
    if book_title in df['Tên sách'].values:
        rating_counts = pd.DataFrame(df['Tên sách'].value_counts())
        rare_books = rating_counts[rating_counts['count'] <= 0].index
        common_books = df[~df['Tên sách'].isin(rare_books)]
        
        if book_title in rare_books:
            print('There are no recommendations for this book')
        else:
            book = user_book_df[book_title]  
            # tính độ tương quan cho sách với các cột
            recom_data = pd.DataFrame(user_book_df.corrwith(book).sort_values(ascending=False)).reset_index(drop=False)   
            low_rating = []
            for i in recom_data['Tên sách']:
                if df[df['Tên sách'] == i]['Điểm đánh giá'].mean() < 3:
                    low_rating.append(i)       
            if recom_data.shape[0] - len(low_rating) > 5:
                recom_data = recom_data[~recom_data['Tên sách'].isin(low_rating)]
            recommended_books = recom_data['Tên sách'].values
            if book_title not in recommended_books:
                recommended_books = np.append(recommended_books, book_title)
            df_new = df[df['Tên sách'].isin(recommended_books)]
            print('độ tương quan',len(df_new))
            #CONTENT-BASED ('Tên sách','Tác giả','Số lượng bán','Thể loại')
            rating_counts = pd.DataFrame(df_new['Tên sách'].value_counts())
        
            rare_books = rating_counts[rating_counts['count'] <= 0].index
    
            common_books = df_new[~df_new['Tên sách'].isin(rare_books)]
            common_books = common_books.drop_duplicates(subset=['Tên sách'])
            common_books.reset_index(inplace= True)
            common_books['index'] = [i for i in range(common_books.shape[0])]   
            target_cols = ['Tên sách','Tác giả','Số lượng bán','Thể loại']
            common_books['combined_features'] = [' '.join(common_books[target_cols].iloc[i,].values) for i in range(common_books[target_cols].shape[0])]
            cv = CountVectorizer()
            count_matrix = cv.fit_transform(common_books['combined_features'])
            cosine_sim = cosine_similarity(count_matrix)
            index = common_books[common_books['Tên sách'] == book_title]['index'].values[0]
            sim_books = list(enumerate(cosine_sim[index]))
            sorted_sim_books = sorted(sim_books,key=lambda x:x[1],reverse=True)
            print(sorted_sim_books)
            books = []
            for i in range(len(sorted_sim_books)):
                if sorted_sim_books[i][1] != 0.0:
                    books.append(common_books[common_books['index'] == sorted_sim_books[i][0]]['Tên sách'].item())
            df_new = df_new[df_new['Tên sách'].isin(books)].head(100)
            print('4 yếu tố',len(df_new))
            #CONTENT-BASED (SUMMARY)
            rating_counts = pd.DataFrame(df_new['Tên sách'].value_counts())
            rare_books = rating_counts[rating_counts['count'] <= 0].index
            common_books = df_new[~df_new['Tên sách'].isin(rare_books)]
            
            common_books = common_books.drop_duplicates(subset=['Tên sách'])
            common_books.reset_index(inplace= True)
            common_books['index'] = [i for i in range(common_books.shape[0])]
            cv = CountVectorizer()
            count_matrix = cv.fit_transform(common_books['keywordSP'])
            cosine_sim = cosine_similarity(count_matrix) 
            index = common_books[common_books['Tên sách'] == book_title]['index'].values[0]
            sim_books = list(enumerate(cosine_sim[index]))
            sorted_sim_books = sorted(sim_books,key=lambda x:x[1],reverse=True)
            print(sorted_sim_books)
            summary_books = []
            for i in range(len(sorted_sim_books)):
                summary_books.append(common_books[common_books['index'] == sorted_sim_books[i][0]]['Tên sách'].item())
            df_new = df_new[df_new['Tên sách'].isin(summary_books)].head(50)
            print('nội dung',len(df_new))
            #TOP RATED OF CATEGORY
            category = df_new[df_new['Tên sách'] == book_title]['Thể loại'].values[0]
            top_rated = df_new[df_new['Thể loại'] == category].groupby('Tên sách').agg({'Điểm đánh giá':'mean'}).reset_index()
            if book_title in [book for book in top_rated['Tên sách']]:
                top_rated = top_rated.drop(top_rated[top_rated['Tên sách'] == book_title].index[0])
            Dexuat1 = df[df['Tên sách'].isin(top_rated['Tên sách'].values)].sort_values(by=['Điểm đánh giá','Số nhận xét'],ascending=False)
            # print(Dexuat1)
            if book_title in [book for book in df_new['Tên sách']]:
                df_new = df_new.drop(df_new[df_new['Tên sách'] == book_title].index[0])
            Dexuat2 = df_new[~df_new['Tên sách'].isin(Dexuat1['Tên sách'].values)].head(10-len(Dexuat1))
            Dexuat = pd.concat([Dexuat1, Dexuat2], ignore_index=True)
            Dexuat = Dexuat[['link', 'Tên sách', 'Tác giả', 'Thể loại', 'Giá bán', 'Số lượng bán', 'Mô tả sản phẩm','Điểm đánh giá', 'Số nhận xét']]
            return Dexuat
# Fill missing values
# user_book_df.fillna(0, inplace=True)

@app.route('/', methods=['GET', 'POST'])
def main():
    if request.method == 'GET':
        return render_template('index.html')
    if request.method == 'POST':
        book_title= request.form["book_title"]
        print(book_title)
        Dexuat=custom_recommender(book_title)
        return render_template('results.html', search_name=book_title, link=Dexuat['link'].values, book_name=Dexuat['Tên sách'].values,
                               author=Dexuat['Tác giả'].values, category=Dexuat['Thể loại'].values, price=Dexuat['Giá bán'].values,
                               sell_number=Dexuat['Số lượng bán'].values, product_description=Dexuat['Mô tả sản phẩm'].values,
                               point_evaluation=Dexuat['Điểm đánh giá'].values, number_comments=Dexuat['Số nhận xét'].values)
#     else:
#         print('Cant find book in dataset, please check spelling')
    
if __name__ == '__main__':
#     # app.run(host="127.0.0.1:5000", port=8080, debug=True)
    app.run(debug=True)