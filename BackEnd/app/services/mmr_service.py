import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from typing import List

class MMRService:
    def __init__(self, lambda_param: float = 0.5):
        self.lambda_param = lambda_param

    def select_top_sentences(self, sentences: List[str], top_n: int = 3) -> List[str]:
        if len(sentences) <= top_n:
            return sentences

        # Vectorize sentences
        vectorizer = TfidfVectorizer()
        tfidf_matrix = vectorizer.fit_transform(sentences)
        
        # Similarity to the "Query" (here, we treat the average vector as the query/central theme)
        query_vec = np.asarray(tfidf_matrix.mean(axis=0))
        sim_to_query = cosine_similarity(tfidf_matrix, query_vec).flatten()
        
        # Similarity between sentences
        sim_matrix = cosine_similarity(tfidf_matrix)

        selected_indices = []
        unselected_indices = list(range(len(sentences)))

        # Start with the sentence most similar to the query
        first_selected = int(np.argmax(sim_to_query))
        selected_indices.append(first_selected)
        unselected_indices.remove(first_selected)

        while len(selected_indices) < top_n:
            mmr_scores = []
            for unselected_idx in unselected_indices:
                relevance = sim_to_query[unselected_idx]
                redundancy = max([sim_matrix[unselected_idx][sel_idx] for sel_idx in selected_indices])
                
                mmr_score = self.lambda_param * relevance - (1 - self.lambda_param) * redundancy
                mmr_scores.append((mmr_score, unselected_idx))
            
            # Select the one with the highest MMR score
            mmr_scores.sort(reverse=True)
            best_idx = mmr_scores[0][1]
            selected_indices.append(best_idx)
            unselected_indices.remove(best_idx)

        return [sentences[i] for i in selected_indices]

mmr_service = MMRService()
